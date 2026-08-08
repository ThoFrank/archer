class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create multiple_new multiple_create ]
  before_action :set_tournament
  def new
    @participant = Participant.new
    @flags = single_registration_flags
  end

  def multiple_new
    @tournament = Tournament.find(params[:tournament_id])
    @flags = multiple_registration_flags
  end

  def create
    part_params = participant_params
    reg_params = registration_params.merge!(tournament: @tournament)

    %w[ first_name last_name club ].each do |p|
      part_params[p].andand.strip!
    end

    @participant = Participant.new(part_params)
    @participant.Tournament = @tournament

    @participant.transaction do
      registration = Registration.create!(reg_params)
      @participant.registration = registration
      @participant.save!
    end

    ParticipantMailer.registration_confirmation(@participant.registration).deliver
    redirect_to tournament_participants_path(@tournament)
  rescue => e
    logger.error "Could not create single registration: #{e}"
    @registration_error = registration_error_message(e)
    @flags = single_registration_flags(existing_archer: archer_flag(part_params, reg_params, empty_group_id: -1))
    render :new, status: :unprocessable_content
  end

  def multiple_create
    part_params = participants_params
    reg_params = registration_params.merge!(tournament: @tournament)

    Participant.transaction do
      @registration = Registration.create!(reg_params)
      part_params.each do |p|
        %w[ first_name last_name club ].each do |field|
          p[field].andand.strip!
        end
        participant = Participant.new(p)
        participant.registration = @registration
        participant.Tournament = @tournament
        participant.save!
      end
    end

    ParticipantMailer.registration_confirmation(@registration).deliver
    redirect_to tournament_participants_path(@tournament)
  rescue => e
    logger.error "Could not create multiple registrations: #{e}"
    @registration_error = registration_error_message(e)
    @flags = multiple_registration_flags(existing_archers: part_params.map { |p| archer_flag(p, reg_params) })
    render :multiple_new, status: :unprocessable_content
  end

  def edit
    @registration = Registration.find(params.expect(:id))
    @flags = {
      form_action_url: tournament_registration_path(@tournament, @registration),
      csrf_token: form_authenticity_token,
      translations: I18n.t("registrations.edit"),
      classes: @tournament.tournament_classes.includes(:target_faces).map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_date}",
          end_dob: "#{cls.to_date}",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archers: @registration.participants.map { |p| {
        id: p.id.to_s,
        first_name: p.first_name,
        last_name: p.last_name,
        club: p.club || "",
        email: p.registration.email || "",
        dob: p.dob || "",
        selected_class: p.tournament_class_id.to_s || "",
        selected_target_face: p.target_face_id.to_s  || "",
        comment: p.registration.comment.to_s,
        group_id: p.group_id || -1
      }},
      require_club: @tournament.enforce_club || false,
      known_clubs: Participant.all.map { |p| p.club }.uniq.compact,
      available_groups: @tournament.groups.map { |g| [ g.id, g.name ] },
      is_edit: true
    }
  end

  def update
    @registration = Registration.find(params.expect(:id))
    part_params = participants_params
    reg_params = registration_params.merge!(tournament: @tournament)
    Participant.transaction do
      begin
        delete_ids = @registration.participant_ids.without(part_params.map { |p| p["id"] }.compact)
        delete_ids.each do |delete_me|
          Participant.find_by(id: delete_me).andand.destroy!
        end
        @registration.participant_ids.filter! { |p| !delete_ids.include?(p.to_s) }
        @registration.update!(reg_params)

        part_params.each do |p|
          %w[ first_name last_name club ].each do |field|
            p[field].andand.strip!
          end
          participant = Participant.exists?(p["id"]) ? Participant.find(p["id"]) : Participant.new
          participant.registration = @registration
          participant.Tournament = @tournament
          p.filter! { |k, v| k != :id }
          participant.attributes = p
          participant.save!(validate: !authenticated?)
        end
      rescue => e
        logger.error "Could not update registration: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end
    ParticipantMailer.registration_changed(@registration).deliver unless params["no_mail"] == "true"
    redirect_to tournament_participants_path(@tournament)
  end

  def destroy
    @registration = Registration.find(params.expect(:id))

    # generate the mail before actually deleting
    mail = ParticipantMailer.registration_cancelation(@registration)

    Registration.transaction do
      @registration.participants.each do |p|
        p.destroy!
      end
      @registration.destroy!
    end

    mail.deliver

    redirect_to tournament_participants_path(@tournament), status: :see_other, notice: "Registration was successfully destroyed."
  end

  private
    def participant_params
      p = params.expect(participant: [ :first_name, :last_name, :club, :dob, :tournament_class, :target_face, :group ]).to_hash
      p["target_face"] = TargetFace.find (p["target_face"])
      p["tournament_class"] = TournamentClass.find p["tournament_class"]
      p["group"] = Group.find p["group"] if p["group"]
      p
    end

    def participants_params
      ps = params.expect(participants: [ [ :id, :first_name, :last_name, :club, :dob, :tournament_class, :target_face, :group ] ]).map(&:to_hash)
      ps.map do |p|
        p["target_face"] = TargetFace.find (p["target_face"])
        p["tournament_class"] = TournamentClass.find p["tournament_class"]
        p["group"] = Group.find p["group"] if p["group"]
        p
      end
    end

    def registration_params
      params.expect(registration: [ :email, :comment ]).to_hash
    end

    def single_registration_flags(existing_archer: nil)
      registration_flags(
        form_action_url: tournament_registrations_path(@tournament),
        existing_archer: existing_archer
      )
    end

    def multiple_registration_flags(existing_archers: [])
      registration_flags(
        form_action_url: tournament_multiple_create_registrations_path(@tournament),
        existing_archers: existing_archers
      )
    end

    def registration_flags(form_action_url:, **extra_flags)
      {
        form_action_url: form_action_url,
        csrf_token: form_authenticity_token,
        translations: I18n.t("registrations.new"),
        classes: @tournament.tournament_classes.includes(:target_faces).map do |cls|
          {
            id: cls.id.to_s,
            name: cls.name,
            start_dob: "#{cls.from_date}",
            end_dob: "#{cls.to_date}",
            possible_target_faces: cls.target_faces
          }
        end,
        require_club: @tournament.enforce_club || false,
        known_clubs: Participant.all.map { |p| p.club }.uniq.compact,
        available_groups: @tournament.groups.filter(&:active?).map { |g| [ g.id, g.name ] },
        is_edit: false
      }.merge(extra_flags)
    end

    def archer_flag(participant_params, registration_params, empty_group_id: nil)
      group = participant_params["group"]

      {
        id: participant_params["id"].to_s,
        first_name: participant_params["first_name"].to_s,
        last_name: participant_params["last_name"].to_s,
        club: participant_params["club"].to_s,
        email: registration_params["email"].to_s,
        dob: participant_params["dob"].to_s,
        selected_class: participant_params["tournament_class"].id.to_s,
        selected_target_face: participant_params["target_face"].id.to_s,
        comment: registration_params["comment"].to_s,
        group_id: group&.id || empty_group_id
      }
    end

    def registration_error_message(error)
      if error.respond_to?(:record) && error.record&.errors&.any?
        error.record.errors.full_messages.to_sentence
      else
        error.message
      end
    end
end
