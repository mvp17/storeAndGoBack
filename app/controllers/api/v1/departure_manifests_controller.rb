class Api::V1::DepartureManifestsController < ApplicationController
  def index
    departure_manifests = DepartureManifest.all
    render json: departure_manifests.map(&:as_json), status: :ok
  end

  def show
    uuid = Cassandra::Uuid.new(params[:id])
    departure_manifest = DepartureManifest.find(uuid)
    if departure_manifest
      render json: departure_manifest.as_json, status: :ok
    else
      render json: { error: 'Departure Manifest not found' }, status: :not_found
    end
  end

  def create
    departure_manifest = DepartureManifest.create(departure_manifest_params)
    if departure_manifest
      render json: departure_manifest.as_json, status: :created
    else
      render json: { errors: 'Failed to create Departure Manifest' }, status: :unprocessable_entity
    end
  end

  def update
    uuid = Cassandra::Uuid.new(params[:id])
    departure_manifest = DepartureManifest.find(uuid)
    if departure_manifest
      updated_departure_manifest = DepartureManifest.update(uuid, departure_manifest_params)
      render json: updated_departure_manifest.as_json, status: :ok
    else
      render json: { errors: 'Failed to update Departure Manifest' }, status: :unprocessable_entity
    end
  end

  def destroy
    uuid = Cassandra::Uuid.new(params[:id])
    departure_manifest = DepartureManifest.find(uuid)
    if departure_manifest
      DepartureManifest.destroy(uuid)
      render json: { message: 'Departure Manifest deleted' }, status: :ok
    else
      render json: { errors: 'Failed to delete Departure Manifest' }, status: :unprocessable_entity
    end
  end

  private

  def departure_manifest_params
    params.require(:departure_manifest).permit(:reference, :departure_date, :destination, containers: [])
  end
end
  