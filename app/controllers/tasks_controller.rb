class TasksController < ApplicationController
  skip_before_action :authenticate
  def create
    task_category = TaskCategory.find params[:taskCategoryId]
    return render_invalid_task_group_task_category if params[:taskGroupId] == tas_category.task_group.id

    task = Task.start_recording task_category, params[:startAt]
    render_start_task_recording task
    render json: {}, status: :ok
  end

  def recording
    render json: {}, status: :ok
  end

  def pending
    render json: {}, status: :ok
  end

  def stop
    render json: {}, status: :ok
  end

  def complete
    render json: {}, status: :ok
  end

  private

  def create_params
    params.permit(:taskGroupId, :taskCategoryId, :status, :startAt)
  end

  def render_invalid_task_group_task_category; end

  def render_start_task_recording(task)
    {
      id: task.id,
      status: task.status,
      startAt: task.start_at,
      endAt: task.end_at,
      duration: 14_400,
      taskGroupId: 1,
      taskCategoryId: 1
    }
  end
end
