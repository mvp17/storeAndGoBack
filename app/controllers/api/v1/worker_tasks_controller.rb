module Api
  module V1
      class WorkerTasksController < ApplicationController
          def index
              worker_tasks = WorkerTask.all
              render json: worker_tasks.map(&:as_json), status: :ok
          end

          def show
              worker_task = WorkerTask.find(params[:id])
              if worker_task
              render json: worker_task.as_json, status: :ok
              else
              render json: { error: 'Worker Task not found' }, status: :not_found
              end
          end

          def create
            worker_task = WorkerTask.create(worker_task_params)
            if worker_task
              render json: worker_task.as_json, status: :created
            else
              render json: { errors: 'Failed to create Worker Task' }, status: :unprocessable_entity
            end
          end

          def update
              worker_task = WorkerTask.find(params[:id])
              if worker_task
                updated_worker_task = WorkerTask.update(params[:id], worker_task_params)
                render json: updated_worker_task.as_json, status: :ok
              else
                render json: { errors: 'Failed to update Worker Task' }, status: :unprocessable_entity
              end
          end

          def destroy
              worker_task = WorkerTask.find(params[:id])
              if worker_task
                WorkerTask.destroy(params[:id])
                render json: { message: 'Worker Task deleted' }, status: :ok
              else
                render json: { errors: 'Failed to delete Worker Task' }, status: :unprocessable_entity
              end
          end

          private

          def worker_task_params
              params.require(:worker_task).permit(:description, :status, containers: [:product_id, :quantity], origin_room: [:name], destination_room: [:name])
          end
      end
  end
end

=begin
  {
    "description": "2",
    "containers": {
        "product_id": 3,
        "quantity": 4
    },
    "origin_room": {
        "name": "5"
    },
    "destination_room": {
        "name": "5"
    },
    "status": 3
  }
=end
