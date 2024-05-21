module Api
    module V1
        class ShipmentsController < ApplicationController
            def index
                shipments = Shipment.all
                render json: shipments.map(&:as_json), status: :ok
            end

            def show
                shipment = Shipment.find(params[:id])
                if shipment
                render json: shipment.as_json, status: :ok
                else
                render json: { error: 'Shipment not found' }, status: :not_found
                end
            end

            def create
                shipment = Shipment.create(shipment_params)
                if shipment
                render json: shipment.as_json, status: :created
                else
                render json: { errors: 'Failed to create Shipment' }, status: :unprocessable_entity
                end
            end

            def update
                shipment = Shipment.find(params[:id])
                if shipment
                updated_shipment = Shipment.update(params[:id], shipment_params)
                render json: updated_shipment.as_json, status: :ok
                else
                render json: { errors: 'Failed to update Shipment' }, status: :unprocessable_entity
                end
            end

            def destroy
                shipment = Shipment.find(params[:id])
                if shipment
                Shipment.destroy(params[:id])
                render json: { message: 'Shipment deleted' }, status: :ok
                else
                render json: { errors: 'Failed to delete Shipment' }, status: :unprocessable_entity
                end
            end

            private

            def shipment_params
                params.require(:shipment).permit(:description, containers: [:productId, :quantity], origin_room: [:name], destination_room: [:name])
            end
        end
    end
end

=begin
    {
        "description": "Description 152",
        "containers": {
            "productId": 14,
            "quantity": 100
        },
        "origin_room": {
            "name": "Room 14"
        },
        "destination_room": {
            "name": "Room Aol"
        }
    }
=end
  