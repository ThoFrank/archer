class TournamentClassesController < ApplicationController
  before_action :set_tournament
  before_action :set_tournament_class, only: %i[ show edit update destroy ]

  # GET /tournament_classes
  def index
    @tournament_classes = @tournament.tournament_classes
  end

  # GET /tournament_classes/1
  def show
  end

  # GET /tournament_classes/new
  def new
    @tournament_class = TournamentClass.new
  end

  # GET /tournament_classes/1/edit
  def edit
  end

  # POST /tournament_classes
  def create
    @tournament_class = TournamentClass.new(tournament_class_params)
    @tournament_class.tournament = @tournament

    respond_to do |format|
      if @tournament_class.save
        format.html { redirect_to tournament_tournament_class_path(@tournament, @tournament_class), notice: "Tournament class was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tournament_classes/1
  def update
    respond_to do |format|
      if @tournament_class.update(tournament_class_params)
        format.html { redirect_to tournament_tournament_class_path(@tournament, @tournament_class), notice: "Tournament class was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tournament_classes/1
  def destroy
    @tournament_class.destroy!

    respond_to do |format|
      format.html { redirect_to tournament_tournament_classes_path(@tournament), status: :see_other, notice: "Tournament class was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params[:tournament_id])
    end

    def set_tournament_class
      @tournament_class = TournamentClass.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tournament_class_params
      params.expect(tournament_class: [ :name, :age_start, :age_end])
    end
end
