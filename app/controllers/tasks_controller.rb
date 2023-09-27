class TasksController < ApplicationController
  def create
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

  def build_task_json(task)
    {
      id: task.id,
      status: task.status,
      startAt: task.start_at.rfc3339,
      endAt: task.end_at&.rfc3339 || '0000-00-00T00:00:00Z',
      duration: task.duration,
      taskGroupId: task.task_category.id,
      taskCategoryId: task.task_category.task_group.id
    }
  end
end
