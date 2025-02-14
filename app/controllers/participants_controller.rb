class ParticipantsController < ApplicationController

  def index
    @tournament = Tournament.find(params[:tournament_id])
    @participants = @tournament.participants
  end

  def new
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.new
    @flags = {
      form_action_url: tournament_path(@tournament) + "/participants",
      csrf_token: form_authenticity_token,
      classes: @tournament.tournament_classes.map do |cls|
        {
          id: cls.id.to_s,
          name: cls.name,
          start_dob: "#{cls.from_dob}-01-01",
          end_dob: "#{cls.to_dob}-12-31",
          possible_target_faces: [],
        }
      end,
    }
  end

  def create
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.new(participant_params)
    @participant.Tournament = @tournament
    if @participant.save
      redirect_to tournament_path(@tournament) + "/participants"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def participant_params
      params.expect(participant: [ :first_name, :last_name, :dob ])
    end

end
