class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create multiple_new multiple_create ]
  before_action :set_tournament
  def new
    @participant = Participant.new
    @flags = {
      form_action_url: tournament_participants_path(@tournament),
      csrf_token: form_authenticity_token,
      translations: I18n.t("participants.new"),
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_date}",
          end_dob: "#{cls.to_date}",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archer: nil,
      require_club: @tournament.enforce_club || false,
      known_clubs: Participant.all.map { |p| p.club }.uniq.compact,
      available_groups: @tournament.groups.filter(&:active?).map { |g| [ g.id, g.name ] }
    }
  end

  def multiple_new
    @tournament = Tournament.find(params[:tournament_id])

    @flags = {
      form_action_url: tournament_multiple_create_participants_path(@tournament),
      csrf_token: form_authenticity_token,
      translations: I18n.t("participants.new"),
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_date}",
          end_dob: "#{cls.to_date}",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archer: nil,
      require_club: @tournament.enforce_club || false,
      known_clubs: Participant.all.map { |p| p.club }.uniq.compact,
      available_groups: @tournament.groups.filter(&:active?).map { |g| [ g.id, g.name ] }
    }
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
      begin
        registration = Registration.create(reg_params)
        @participant.registration = registration
        @participant.save!
      rescue => e
        logger.error "Could not create single registration: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end

    ParticipantMailer.registration_confirmation(@participant.registration).deliver
    redirect_to tournament_participants_path(@tournament)
  end

  def multiple_create
    part_params = participants_params
    reg_params = registration_params.merge!(tournament: @tournament)
    Participant.transaction do
      begin
        @registration = Registration.create(reg_params)
        part_params.each do |p|
          puts "Part params: #{p}"
          %w[ first_name last_name club ].each do |field|
            p[field].andand.strip!
          end
          participant = Participant.new(p)
          participant.registration = @registration
          participant.Tournament = @tournament
          participant.save!
        end
      rescue => e
        logger.error "Could not create multiple registrations: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end
    ParticipantMailer.registration_confirmation(@registration).deliver
    redirect_to tournament_participants_path(@tournament)
  end

  def edit
    @registration = Registration.find(params.expect(:id))
    @flags = {
      form_action_url: tournament_registration_path(@tournament, @registration),
      csrf_token: form_authenticity_token,
      translations: I18n.t("participants.edit"),
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_date}",
          end_dob: "#{cls.to_date}",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archers: @registration.participants.map { |p| {
        first_name: p.first_name,
        last_name: p.last_name,
        club: p.club || "",
        email: p.registration.email || "",
        dob: p.dob || "",
        selected_class: p.tournament_class.andand.id.to_s || "",
        selected_target_face: p.target_face.andand.id.to_s  || "",
        comment: p.registration.comment.to_s,
        group_id: p.group_id || -1
      }},
      require_club: @tournament.enforce_club || false,
      known_clubs: Participant.all.map { |p| p.club }.uniq.compact,
      available_groups: @tournament.groups.map { |g| [ g.id, g.name ] }
    }
  end

  def update
    @registration = Registration.find(params.expect(:id))
    part_params = participants_params
    reg_params = registration_params.merge!(tournament: @tournament)
    Participant.transaction do
      begin
        # TODO don't delete and recreate participants
        @registration.participants.each do |p|
          p.destroy!
        end
        part_params.each do |p|
          puts "Part params: #{p}"
          %w[ first_name last_name club ].each do |field|
            p[field].andand.strip!
          end
          participant = Participant.new(p)
          participant.registration = @registration
          participant.Tournament = @tournament
          participant.save!
        end
      rescue => e
        logger.error "Could not update registration: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end
    ParticipantMailer.registration_confirmation(@registration).deliver
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
      ps = params.expect(participants: [ [ :first_name, :last_name, :club, :dob, :tournament_class, :target_face, :group ] ]).map(&:to_hash)
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
end
