class TournamentImport
  class Error < StandardError; end

  SETTINGS = %w[ name description place date_start date_end season_start_date status enforce_club prevent_duplicate_registrations mail_text ].freeze

  def initialize(tournament, data, mode: "add_new")
    @tournament = tournament
    @data = data
    @mode = mode
    @maps = {}
  end

  def call
    validate_data!
    @tournament.with_lock do
      # Snapshot before creating anything: generated IDs can collide with IDs later in the file.
      @existing = {
        groups: @tournament.groups.index_by(&:id),
        target_faces: @tournament.target_faces.index_by(&:id),
        tournament_classes: @tournament.tournament_classes.index_by(&:id),
        registrations: Registration.where(tournament: @tournament).index_by(&:id),
        participants: @tournament.participants.index_by(&:id)
      }
      @tournament.update!(@data.fetch("tournament").slice(*SETTINGS)) if overwrite?
      import_records(:groups, @tournament.groups, %w[ name status ])
      import_records(:target_faces, @tournament.target_faces, %w[ name distance size ])
      import_records(:tournament_classes, @tournament.tournament_classes, %w[ name age_start age_end price ianseo_name ianseo_division ]) do |record, row|
        record.target_faces = row.fetch("target_face_ids").map { |id| reference(:target_faces, id) }
      end
      import_participants if @data.key?("participants")
    end
    self
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ArgumentError => e
    raise Error, e.message
  end

  private
    def overwrite?
      @mode == "overwrite"
    end

    def validate_data!
      raise Error, "Invalid import mode" unless %w[ add_new overwrite ].include?(@mode)
      raise Error, "Expected a tournament export object" unless @data.is_a?(Hash) && @data["tournament"].is_a?(Hash)

      %w[ groups target_faces tournament_classes participants ].each do |section|
        next if section == "participants" && !@data.key?(section)
        rows = @data[section]
        raise Error, "Expected an array for #{section}" unless rows.is_a?(Array)
        ids = rows.map do |row|
          raise Error, "Invalid record in #{section}" unless row.is_a?(Hash)
          source_id(row["id"])
        end
        raise Error, "Duplicate IDs in #{section}" unless ids.uniq.length == ids.length
      end
      @data.fetch("tournament_classes").each do |row|
        raise Error, "Expected target_face_ids for each class" unless row["target_face_ids"].is_a?(Array)
      end
    end

    def source_id(value)
      raise Error, "IDs must be positive integers" unless value.is_a?(Integer) && value.positive?
      value
    end

    def reference(section, id)
      @maps.fetch(section).fetch(source_id(id)) { raise Error, "Unknown #{section} ID: #{id}" }
    end

    def import_records(section, association, fields)
      @maps[section] = {}
      @data.fetch(section.to_s).each do |row|
        existing = @existing.fetch(section)[row.fetch("id")]
        record = existing || association.build
        if existing.nil? || overwrite?
          record.assign_attributes(row.slice(*fields))
          yield record, row if block_given?
          record.save!
        end
        @maps[section][row.fetch("id")] = record
      end
    end

    def import_participants
      @maps[:registrations] = {}
      registration_rows = {}
      @data.fetch("participants").each do |row|
        next if @existing[:participants].key?(row.fetch("id")) && !overwrite?
        registration = row["registration"]
        next if registration.nil?
        raise Error, "Invalid registration" unless registration.is_a?(Hash)
        id = source_id(registration["id"])
        if registration_rows.key?(id) && registration_rows[id] != registration
          raise Error, "Conflicting registration ID: #{id}"
        end
        registration_rows[id] = registration
      end
      registration_rows.each do |id, row|
        existing = @existing[:registrations][id]
        record = existing || Registration.new(tournament: @tournament)
        if existing.nil? || overwrite?
          record.assign_attributes(row.slice("email", "comment"))
          record.save!
        end
        @maps[:registrations][id] = record
      end

      @data.fetch("participants").each do |row|
        existing = @existing[:participants][row.fetch("id")]
        next if existing && !overwrite?
        participant = existing || Participant.new(Tournament: @tournament)
        participant.assign_attributes(row.slice("first_name", "last_name", "dob", "club"))
        participant.group = reference(:groups, row["group_id"]) if row["group_id"]
        participant.group = nil unless row["group_id"]
        participant.tournament_class = reference(:tournament_classes, row["tournament_class_id"])
        participant.target_face = reference(:target_faces, row["target_face_id"])
        # Restore historical registrations even if today's age/club/group rules would reject them.
        participant.save!(validate: false)
        registration = row["registration"] && reference(:registrations, row["registration"]["id"])
        link = participant.registration_participant
        if registration
          link ||= participant.build_registration_participant
          link.update!(registration: registration)
        else
          link&.destroy!
        end
      end
    end
end
