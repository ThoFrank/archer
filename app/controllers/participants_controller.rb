class ParticipantsController < ApplicationController

  def index
    @tournament = Tournament.find(params[:tournament_id])
    @participants = @tournament.participants
  end

  def new
    @tournament = Tournament.find(params[:tournament_id])
    @participant = Participant.new
    @participants_path = tournament_path(@tournament) + "/participants"
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
