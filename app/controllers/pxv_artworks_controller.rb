class PxvArtworksController < ApplicationController
  before_action :set_pxv_artwork, only: %i[ show edit update destroy ]

  # GET /pxv_artworks or /pxv_artworks.json
  def index
    @pxv_artworks = PxvArtwork.all
  end

  # GET /pxv_artworks/1 or /pxv_artworks/1.json
  def show
  end

  # GET /pxv_artworks/new
  def new
    @pxv_artwork = PxvArtwork.new
  end

  # GET /pxv_artworks/1/edit
  def edit
  end

  # POST /pxv_artworks or /pxv_artworks.json
  def create
    @pxv_artwork = PxvArtwork.new(pxv_artwork_params)

    respond_to do |format|
      if @pxv_artwork.save
        format.html { redirect_to @pxv_artwork, notice: "Pxv artwork was successfully created." }
        format.json { render :show, status: :created, location: @pxv_artwork }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pxv_artwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pxv_artworks/1 or /pxv_artworks/1.json
  def update
    respond_to do |format|
      if @pxv_artwork.update(pxv_artwork_params)
        format.html { redirect_to @pxv_artwork, notice: "Pxv artwork was successfully updated." }
        format.json { render :show, status: :ok, location: @pxv_artwork }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pxv_artwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pxv_artworks/1 or /pxv_artworks/1.json
  def destroy
    @pxv_artwork.destroy!

    respond_to do |format|
      format.html { redirect_to pxv_artworks_path, status: :see_other, notice: "Pxv artwork was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pxv_artwork
      @pxv_artwork = PxvArtwork.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pxv_artwork_params
      params.expect(pxv_artwork: [ :artwork_id, :user_id, :title, :state, :rating, :release_date, :number_of_pic, :remarks ])
    end
end
