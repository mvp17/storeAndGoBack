module Api
    module V1
        class TechnicianTasksController < ApplicationController
            def index
                technician_tasks = TechnicianTask.all
                render json: technician_tasks.map(&:as_json), status: :ok
            end

            def show
                uuid = Cassandra::Uuid.new(params[:id])
                technician_task = TechnicianTask.find(uuid)
                if technician_task
                    render json: technician_task.as_json, status: :ok
                else
                    render json: { error: 'TechnicianTask not found' }, status: :not_found
                end
            end

            def create
                technician_task = TechnicianTask.create(technician_task_params)
                if technician_task
                    render json: technician_task.as_json, status: :created
                else
                    render json: { errors: 'Failed to create TechnicianTask' }, status: :unprocessable_entity
                end
            end

            def update
                uuid = Cassandra::Uuid.new(params[:id])
                technician_task = TechnicianTask.find(uuid)
                if technician_task
                    updated_technician_task = TechnicianTask.update(uuid, technician_task_params)
                    render json: updated_technician_task.as_json, status: :ok
                else
                    render json: { errors: 'Failed to update TechnicianTask' }, status: :unprocessable_entity
                end
            end

            def destroy
                uuid = Cassandra::Uuid.new(params[:id])
                technician_task = TechnicianTask.find(uuid)
                if technician_task
                    TechnicianTask.destroy(uuid)
                    render json: { message: 'TechnicianTask deleted' }, status: :ok
                else
                    render json: { errors: 'Failed to delete TechnicianTask' }, status: :unprocessable_entity
                end
            end

            private

            def technician_task_params
                params.require(:technician_task).permit(:priority, :description, :room, :detail, :status, :date)
            end
        end
    end
end

=begin
    {
        priority: 0,
        description: "Desc 8521 todo",
        room: "Room M1",
        detail: "Detail 41785",
        status: 0,
        date: "01/01/2023"
    } 
=end
