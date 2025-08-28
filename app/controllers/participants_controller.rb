class ParticipantsController < ApplicationController
  allow_unauthenticated_access only: %i[ index new create multiple_new multiple_create ]
  before_action :set_tournament

  def index
    @participants = @tournament.participants
    respond_to do |format|
      format.html
      format.csv do
        if authenticated?
          response.headers["Content-Type"] = "text/csv"
          if params[:query] == "ianseo"
            response.headers["Content-Disposition"] = "attachment; filename=#{@tournament.name}_participants.ianseo.csv"
            render template: "participants/index_ianseo"
          else
            response.headers["Content-Disposition"] = "attachment; filename=#{@tournament.name}_participants.csv"
            render template: "participants/index"
          end
        else
          request_authentication
        end
      end
    end
  end

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
      existing_archer: nil
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
      existing_archer: nil
    }
  end

  def create
    part_params = participant_params
    reg_params = registration_params.merge!(tournament: @tournament)

    %w[ first_name last_name ].each do |p|
      part_params[p].strip!
    end

    @participant = Participant.new(part_params)
    @participant.Tournament = @tournament

    @participant.transaction do
      begin
        registration = Registration.create(reg_params)
        @participant.registration = registration
        @participant.save!
      rescue => e
        logger.error "Could not create participant: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end

    ParticipantMailer.registration_confirmation(@participant).deliver
    redirect_to tournament_participants_path(@tournament)
  end

  def multiple_create
    part_params = participants_params
    reg_params = registration_params.merge!(tournament: @tournament)
    raise "Can't handle anything except exactly one participant for now" unless part_params.length == 1
    params["participant"] = params["participants"].first
    create
  end

  def edit
    @participant = Participant.find(params.expect(:id))
    @flags = {
      form_action_url: tournament_participant_path(@tournament, @participant),
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
      existing_archer: {
        first_name: @participant.first_name,
        last_name: @participant.last_name,
        email: @participant.registration.email || "",
        dob: @participant.dob || "",
        selected_class: @participant.tournament_class.andand.id.to_s || "",
        selected_target_face: @participant.target_face.andand.id.to_s  || "",
        comment: @participant.registration.comment.to_s
      }
    }
  end

  def update
    @participant = Participant.find(params.expect(:id))

    part_params = participant_params
    reg_params = registration_params

    %w[ first_name last_name ].each do |p|
      part_params[p].strip!
    end

    logger.debug "Updating participant with #{params}"
    @participant.transaction do
      begin
        @participant.registration.update!(reg_params)
        @participant.update!(part_params)
      rescue => e
        logger.error "Could not update participant: #{e}"
        render :new, status: :unprocessable_content
        return
      end
    end

    ParticipantMailer.registration_changed(@participant).deliver
    redirect_to tournament_participants_path(@tournament)
  end

  def destroy
    @participant = Participant.find(params.expect(:id))
    ParticipantMailer.registration_cancelation(@participant).deliver
    @participant.destroy!

    redirect_to tournament_participants_path(@tournament), status: :see_other, notice: "Participant was successfully destroyed."
  end

  private
    def participant_params
      p = params.expect(participant: [ :first_name, :last_name, :dob, :tournament_class, :target_face ]).to_hash
      p["target_face"] = TargetFace.find (p["target_face"])
      p["tournament_class"] = TournamentClass.find p["tournament_class"]
      p
    end

    def participants_params
      ps = params.expect(participants: [[ :first_name, :last_name, :dob, :tournament_class, :target_face ]]).map(&:to_hash)
      ps.map do |p|
        p["target_face"] = TargetFace.find (p["target_face"])
        p["tournament_class"] = TournamentClass.find p["tournament_class"]
      end
    end

    def registration_params
      params.expect(registration: [ :email, :comment ]).to_hash
    end
end
