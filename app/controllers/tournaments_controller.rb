class TournamentsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tournament, only: %i[ show edit update destroy]

  def index
    @tournaments = Tournament.all
  end

  def show
    if !authenticated? && @tournament.status == "archived"
      raise ActiveRecord::RecordNotFound
    end
  end

  def new
    @tournament = Tournament.new
    @tournament.season_start_date = Date.new(Date.today.year)
  end

  def create
    @tournament = Tournament.new(tournament_params)

    if @tournament.save
      redirect_to @tournament
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tournament.update(tournament_params)
      redirect_to @tournament
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tournament.participants.each(&:destroy)
    redirect_to tournament_path(@tournament), status: :see_other, notice: "Tournament destroyed."
  end

  private
    def tournament_params
      params.expect(tournament: [
        :name,
        :description,
        :place,
        :date_start,
        :date_end,
        :season_start_date,
        :status
      ])
    end
end
