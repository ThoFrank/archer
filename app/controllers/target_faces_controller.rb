class TargetFacesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tournament
  before_action :set_target_face, only: %i[ show edit update destroy ]

  def index
    @target_faces = @tournament.target_faces
  end

  # GET /target_faces/1
  def show
  end

  # GET /target_faces/new
  def new
    @target_face = TargetFace.new
  end

  # GET /target_faces/1/edit
  def edit
  end

  # POST /target_faces
  def create
    @target_face = TargetFace.new(target_face_params)
    @target_face.tournament = @tournament

    respond_to do |format|
      if @target_face.save
        format.html { redirect_to tournament_target_face_path(@tournament, @target_face), notice: "Target face was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /target_faces/1
  def update
    respond_to do |format|
      if @target_face.update(target_face_params)
        format.html { redirect_to tournament_target_face_path(@tournament, @target_face), notice: "Target face was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /target_faces/1
  def destroy
    @target_face.destroy!

    respond_to do |format|
      format.html { redirect_to tournament_target_faces_path, status: :see_other, notice: "Target face was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params.expect(:tournament_id))
    end

    def set_target_face
      @target_face = TargetFace.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def target_face_params
      params.expect(target_face: [ :name, :distance, :size ])
    end
end
