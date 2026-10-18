class TournamentsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tournament, only: %i[ show edit update destroy export import ]

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

  def export
    export = TournamentExport.new(@tournament, include_participants: ActiveModel::Type::Boolean.new.cast(params[:include_participants]))
    send_data JSON.pretty_generate(export.as_json),
      filename: "#{@tournament.name.to_s.parameterize.presence || "tournament"}.json",
      type: "application/json",
      disposition: "attachment"
  end

  def import
    file = params[:file]
    raise TournamentImport::Error, t("tournaments.show.Select a JSON file") unless file.respond_to?(:read)

    TournamentImport.new(@tournament, JSON.parse(file.read), mode: params[:mode] || "add_new").call
    redirect_to @tournament, notice: t("tournaments.show.Import successful")
  rescue JSON::ParserError
    redirect_to @tournament, alert: t("tournaments.show.Invalid JSON file")
  rescue TournamentImport::Error => e
    redirect_to @tournament, alert: t("tournaments.show.Import failed", error: e.message)
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
        :status,
        :enforce_club,
        :prevent_duplicate_registrations,
        :mail_text
      ])
    end
end
