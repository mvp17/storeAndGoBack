class Api::V1::EntranceManifestsController < ApplicationController
  # GET /api/v1/entranceManifests
  def index
    entrance_manifests = EntranceManifest.all
    render json: entrance_manifests.map(&:as_json), status: :ok
  end

  # GET /api/v1/entranceManifests/:id
  def show
    entrance_manifest = EntranceManifest.find(params[:id])
    if entrance_manifest
      render json: entrance_manifest.as_json, status: :ok
    else
      render json: { error: 'Entrance Manifest not found' }, status: :not_found
    end
  end

  # POST /api/v1/entranceManifests
  def create
    entrance_manifest = EntranceManifest.create(entrance_manifest_params)
    if entrance_manifest
      render json: entrance_manifest.as_json, status: :created
    else
      render json: { errors: 'Failed to create Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/entranceManifests/:id
  def update
    entrance_manifest = EntranceManifest.find(params[:id])
    if entrance_manifest
      updated_entrance_manifest = EntranceManifest.update(params[:id], entrance_manifest_params)
      render json: updated_entrance_manifest.as_json, status: :ok
    else
      render json: { errors: 'Failed to update Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/entranceManifests/:id
  def destroy
    entrance_manifest = EntranceManifest.find(params[:id])
    if entrance_manifest
      EntranceManifest.destroy(params[:id])
      render json: { message: 'Entrance Manifest deleted' }, status: :ok
    else
      render json: { errors: 'Failed to delete Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  private

  def entrance_manifest_params
    params.require(:entrance_manifest).permit(:entrance_date, :origin, :reference)
  end
end

=begin
  {
    "entrance_date": "2024-12-20",
    "origin": "test_origin852",
    "reference": "test_reference 956"
  }
=end