class ParticipantsController < ApplicationController
  allow_unauthenticated_access only: %i[ index new create]
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

  def create
    params = participant_params.to_hash
    params["target_face"] = TargetFace.find (params["target_face"])
    params["tournament_class"] = TournamentClass.find params["tournament_class"]

    %w[ first_name last_name ].each do |p|
      params[p].strip!
    end
    email = params.delete "email"
    comment = params.delete "comment"

    @participant = Participant.new(params)
    @participant.Tournament = @tournament

    @participant.transaction do
      begin
        registration = Registration.create(email: email, tournament: @tournament, comment: comment)
        @participant.registration = registration
        @participant.save!
      rescue
        render :new, status: :unprocessable_entity
      end
    end

    ParticipantMailer.registration_confirmation(@participant).deliver
    redirect_to tournament_participants_path(@tournament)
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
    params = participant_params.to_hash
    params["target_face"] = TargetFace.find (params["target_face"])
    params["tournament_class"] = TournamentClass.find params["tournament_class"]

    %w[ first_name last_name ].each do |p|
      params[p].strip!
    end
    email = params.delete "email"

    logger.debug "Updating participant with #{params}"
    @participant.transaction do
      begin
        @participant.registration.update!(email: email, comment: params.delete("comment"))
        @participant.update!(params)
      rescue
        render :new, status: :unprocessable_entity
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
      params.expect(participant: [ :first_name, :last_name, :email, :dob, :tournament_class, :target_face, :comment ])
    end
end
