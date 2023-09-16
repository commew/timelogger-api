class TasksController < ApplicationController
  skip_before_action :authenticate
  def create
    render json: {}, status: :ok
  end

  def recording
    task_ids = Task
      .joins(:task_time_units)
      .merge(TaskTimeUnit.where(end_at: nil))
      .pluck(:id)

    tasks = Task.preload(:task_time_units).where(id: task_ids)

    render json: {
      tasks: tasks.map do |task|
        {
          id: task.id,
          status: 'recording',
          startAt: task.start_at&.rfc3339,
          endAt: task.end_at&.rfc3339,
          duration: task.duration,
          taskGroupId: task.task_category.id,
          taskCategoryId: task.task_category.task_group.id
        }
      end
    }, status: :ok
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
end
