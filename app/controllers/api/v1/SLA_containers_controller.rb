module Api
  module V1
    class SlaContainersController < ApplicationController
      # GET /api/v1/sla_containers
      def index
        sla_containers = SLAContainer.all
        render json: sla_containers.map(&:as_json)
      end

      # GET /api/v1/sla_containers/:id
      def show
        uuid = Cassandra::Uuid.new(params[:id])
        sla_container = SLAContainer.find(uuid)
        if sla_container
          render json: sla_container.as_json, status: :ok
        else
          render json: { error: 'SLA Container not found' }, status: :not_found
        end
      end

      # POST /api/v1/sla_containers
      def create
        sla_container = SLAContainer.create(sla_container_params)
        if sla_container
          render json: sla_container.as_json, status: :created
        else
          render json: { error: 'Failed to create SLA Container' }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/sla_containers/:id
      def update
        uuid = Cassandra::Uuid.new(params[:id])
        sla_container = SLAContainer.find(uuid)
        if sla_container
          updated_sla_container = SLAContainer.update(uuid, sla_container_params)
          render json: updated_sla_container.as_json, status: :ok
        else
          render json: { error: 'Failed to update SLA Container' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/sla_containers/:id
      def destroy
        sla_container = SLAContainer.find(params[:id])
        if sla_container
          SLAContainer.destroy(params[:id])
          render json: { message: 'SLA Container deleted' }, status: :ok
        else
          render json: { error: 'Failed to delete SLA Container' }, status: :unprocessable_entity
        end
      end

      private
      
      def sla_container_params
        params.require(:sla_container).permit(:quantity, :product, :producer, :min_temp, :max_temp, :min_hum, :max_hum, :date_limit)
      end
    end
  end
end
