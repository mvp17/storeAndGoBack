module Api
  module V1
    class RoomsController < ApplicationController
      def index
        rooms = Room.all
        render json: rooms.map(&:as_json), status: :ok
      end

      def show
        uuid = Cassandra::Uuid.new(params[:id])
        room = Room.find(uuid)
        if room
          render json: room.as_json, status: :ok
        else
          render json: { error: 'Room not found' }, status: :not_found
        end
      end

      def create
        room = Room.create(room_params)
        if room
          render json: room.as_json, status: :created
        else
          render json: { errors: 'Failed to create Room' }, status: :unprocessable_entity
        end
      end

      def update
        uuid = Cassandra::Uuid.new(params[:id])
        room = Room.find(uuid)
        if room
          updated_room = Room.update(uuid, room_params)
          render json: updated_room.as_json, status: :ok
        else
          render json: { errors: 'Failed to update Room' }, status: :unprocessable_entity
        end
      end

      def destroy
        uuid = Cassandra::Uuid.new(params[:id])
        room = Room.find(uuid)
        if room
          Room.destroy(params[:id])
          render json: { message: 'Room deleted' }, status: :ok
        else
          render json: { errors: 'Failed to delete Room' }, status: :unprocessable_entity
        end
      end

      private

      def room_params
        params.require(:room).permit(:room_status, :name, :temp, :hum, :quantity, :threshold)
      end
    end
  end
end
  
=begin
  {
    "room_status": 0,
    "name": "Sala Apr",
    "temp": 22,
    "hum": 17,
    "quantity": 1,
    "threshold": 20
  }
=end
