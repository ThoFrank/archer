class TournamentsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  def index
    @tournaments = Tournament.all
  end

  def show
    @tournament = Tournament.find(params[:id])
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
    @tournament = Tournament.find(params[:id])
  end

  def update
    @tournament = Tournament.find(params[:id])
    if @tournament.update(tournament_params)
      redirect_to @tournament
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def tournament_params
      params.expect(tournament: [
        :name,
        :description,
        :place,
        :date_start,
        :date_end,
        :season_start_date
      ])
    end
end
