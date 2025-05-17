class Api::V1::EntranceManifestsController < ApplicationController
  def index
    entrance_manifests = EntranceManifest.all
    render json: entrance_manifests.map(&:as_json), status: :ok
  end

  def show
    uuid = Cassandra::Uuid.new(params[:id])
    entrance_manifest = EntranceManifest.find(uuid)
    if entrance_manifest
      render json: entrance_manifest.as_json, status: :ok
    else
      render json: { error: 'Entrance Manifest not found' }, status: :not_found
    end
  end

  def create
    entrance_manifest = EntranceManifest.create(entrance_manifest_params)
    if entrance_manifest
      render json: entrance_manifest.as_json, status: :created
    else
      render json: { errors: 'Failed to create Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  def update
    uuid = Cassandra::Uuid.new(params[:id])
    entrance_manifest = EntranceManifest.find(uuid)
    if entrance_manifest
      updated_entrance_manifest = EntranceManifest.update(uuid, entrance_manifest_params)
      render json: updated_entrance_manifest.as_json, status: :ok
    else
      render json: { errors: 'Failed to update Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  def destroy
    uuid = Cassandra::Uuid.new(params[:id])
    entrance_manifest = EntranceManifest.find(uuid)
    if entrance_manifest
      EntranceManifest.destroy(uuid)
      render json: { message: 'Entrance Manifest deleted' }, status: :ok
    else
      render json: { errors: 'Failed to delete Entrance Manifest' }, status: :unprocessable_entity
    end
  end

  private

  def entrance_manifest_params
    params.require(:entrance_manifest).permit(:entrance_date, :origin, :reference, containers: [])
  end
end
