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
                    render json: { error: 'WorkerTask not found' }, status: :not_found
                end
            end

            def create
                worker_task = WorkerTask.create(worker_task_params)
                if worker_task
                    render json: worker_task.as_json, status: :created
                else
                    render json: { errors: 'Failed to create WorkerTask' }, status: :unprocessable_entity
                end
            end

            def update
                worker_task = WorkerTask.find(params[:id])
                if worker_task
                    updated_worker_task = WorkerTask.update(params[:id], worker_task_params)
                    render json: updated_worker_task.as_json, status: :ok
                else
                    render json: { errors: 'Failed to update WorkerTask' }, status: :unprocessable_entity
                end
            end

            def destroy
                worker_task = WorkerTask.find(params[:id])
                if worker_task
                    WorkerTask.destroy(params[:id])
                    render json: { message: 'WorkerTask deleted' }, status: :ok
                else
                    render json: { errors: 'Failed to delete WorkerTask' }, status: :unprocessable_entity
                end
            end

            private

            def worker_task_params
                params.require(:worker_task).permit(:type, :description, :room, :detail, :status, :date)
            end
        end
    end
end
  