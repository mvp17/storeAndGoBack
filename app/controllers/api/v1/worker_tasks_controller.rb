module Api
  module V1
    class WorkerTasksController < ApplicationController
      def index
        worker_tasks = WorkerTask.all
        render json: worker_tasks.map(&:as_json), status: :ok
      end

      def show
        uuid = Cassandra::Uuid.new(params[:id])
        worker_task = WorkerTask.find(uuid)
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
        uuid = Cassandra::Uuid.new(params[:id])
        worker_task = WorkerTask.find(uuid)
        if worker_task
          updated_worker_task = WorkerTask.update(uuid, worker_task_params)
          render json: updated_worker_task.as_json, status: :ok
        else
          render json: { errors: 'Failed to update Worker Task' }, status: :unprocessable_entity
        end
      end

      def destroy
        uuid = Cassandra::Uuid.new(params[:id])
        worker_task = WorkerTask.find(uuid)
        if worker_task
          WorkerTask.destroy(uuid)
          render json: { message: 'Worker Task deleted' }, status: :ok
        else
          render json: { errors: 'Failed to delete Worker Task' }, status: :unprocessable_entity
        end
      end

      def by_room
        uuid_room_id = Cassandra::Uuid.new(params[:room_id])
        tasks = WorkerTask.find_tasks_by_room_id(uuid_room_id)
        puts tasks
        render json: tasks.map(&:as_json), status: :ok
      end

      private

      def worker_task_params
        params.require(:worker_task).permit(:description, :status, :origin_room, :destination_room, containers: [])
      end
    end
  end
end
