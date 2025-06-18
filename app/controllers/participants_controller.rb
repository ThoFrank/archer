class ParticipantsController < ApplicationController
  allow_unauthenticated_access only: %i[ index new create]

  def index
    @tournament = Tournament.find(params[:tournament_id])
    @participants = @tournament.participants
    respond_to do |format|
      format.html
      format.csv do
        if authenticated?
          response.headers["Content-Type"] = "text/csv"
          response.headers["Content-Disposition"] = "attachment; filename=#{@tournament.name}_participants.csv"
          render template: "participants/index"
        else
          request_authentication
        end
    end
    end
  end

  def new
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.new
    @flags = {
      form_action_url: tournament_participants_path(@tournament),
      csrf_token: form_authenticity_token,
      translations: I18n.t("participants.new"),
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_dob}-01-01",
          end_dob: "#{cls.to_dob}-12-31",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archer: nil
    }
  end

  def create
    @tournament = Tournament.find(params[:tournament_id])

    params = participant_params.to_hash
    params["target_face"] = TargetFace.find (params["target_face"])
    params["tournament_class"] = TournamentClass.find params["tournament_class"]
    %w[ first_name last_name ].each do |p|
      params[p].strip!
    end

    @participant = Participant.new(params)
    @participant.Tournament = @tournament
    if @participant.save
      ParticipantMailer.registration_confirmation(@participant).deliver
      redirect_to tournament_participants_path(@tournament)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.find(params.expect(:id))
    @flags = {
      form_action_url: tournament_participant_path(@tournament, @participant),
      csrf_token: form_authenticity_token,
      translations: I18n.t("participants.edit"),
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_dob}-01-01",
          end_dob: "#{cls.to_dob}-12-31",
          possible_target_faces: cls.target_faces
        }
      end,
      existing_archer: {
        first_name: @participant.first_name,
        last_name: @participant.last_name,
        email: @participant.email || "",
        dob: @participant.dob || "",
        selected_class: @participant.tournament_class.andand.id.to_s || "",
        selected_target_face: @participant.target_face.andand.id.to_s  || ""
      }
    }
  end

  def update
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.find(params.expect(:id))
    params = participant_params.to_hash
    params["target_face"] = TargetFace.find (params["target_face"])
    params["tournament_class"] = TournamentClass.find params["tournament_class"]
    logger.debug "Updating participant with #{params}"
    if @participant.update(params)
      redirect_to tournament_participants_path(@tournament)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def participant_params
      params.expect(participant: [ :first_name, :last_name, :email, :dob, :tournament_class, :target_face ])
    end
end
