class Api::V1::SlaContainersController < ApplicationController
  before_action :set_sla_container, only: %i[show update destroy]

  # GET /api/v1/sla_containers
  def index
    @sla_containers = SLAContainer.all
    render json: @sla_containers.map(&:as_json)
  end

  # GET /api/v1/sla_containers/:id
  def show
    render json: @sla_container.as_json
  end

  # POST /api/v1/sla_containers
  def create
    @sla_container = SLAContainer.create(sla_container_params)
    if @sla_container
      render json: @sla_container.as_json, status: :created
    else
      render json: { error: 'Failed to create SLA Container' }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/sla_containers/:id
  def update
    @sla_container = SLAContainer.update(params[:id], sla_container_params)
    if @sla_container
      render json: @sla_container.as_json
    else
      render json: { error: 'Failed to update SLA Container' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/sla_containers/:id
  def destroy
    if SLAContainer.destroy(params[:id])
      head :no_content
    else
      render json: { error: 'Failed to delete SLA Container' }, status: :unprocessable_entity
    end
  end

  private

  def set_sla_container
    @sla_container = SLAContainer.find(params[:id])
    render json: { error: 'SLA Container not found' }, status: :not_found unless @sla_container
  end

  def sla_container_params
    params.require(:sla_container).permit(:quantity, product: [:productId, :producerId], sla: [:SLA, :minTemp, :maxTemp, :minHum, :maxHum, :date_limit])
  end
end
  
=begin
{
  product: {
    productId: 0,
    producerId: 0
  },
  quantity: 10,
  sla: {
    SLA: "sla 1",
    minTemp: 10,
    maxTemp: 30,
    minHum: 20,
    maxHum: 40,
    date_limit: "01/01/2024"
  }
}
=end
