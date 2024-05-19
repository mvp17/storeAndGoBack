class Api::V1::EntranceManifestsController < ApplicationController
  # GET /api/v1/entranceManifests
  def index
    render json: EntranceManifest.all
  end

  # GET /api/v1/entranceManifests/:id
  def show
    id = Cassandra::Uuid.new(params[:id])
    record = YourModel.find(id)
    if record
      render json: record
    else
      render json: { error: 'Record not found' }, status: :not_found
    end
  end

  # POST /api/v1/entranceManifests
  def create
    EntranceManifest.create(ref: params[:ref], date: params[:date], origin: params[:origin])
    render json: { message: 'Record created successfully' }, status: :created
  end

  # PUT /api/v1/entranceManifests/:id
  def update
    id = Cassandra::Uuid.new(params[:id])
    EntranceManifest.update(id, params[:ref], date: params[:date], origin: params[:origin])
    render json: { message: 'Record updated successfully' }
  end

  # DELETE /api/v1/entranceManifests/:id
  def destroy
    id = Cassandra::Uuid.new(params[:id])
    EntranceManifest.destroy(id)
    render json: { message: 'Record deleted successfully' }
  end
end
