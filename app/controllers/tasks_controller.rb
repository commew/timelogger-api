class TasksController < ApplicationController
  def create
    render json: {}, status: :ok
  end

  def recording
    task_ids = Task
               .joins(:task_time_units)
               .joins(task_category: :task_group)
               .merge(TaskTimeUnit.where(end_at: nil))
               .merge(TaskGroup.where(account_id: @account))
               .pluck(:id)

    render_tasks Task.preload(:task_time_units).where(id: task_ids)
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

  def render_tasks(tasks)
    render json: {
      tasks: tasks.map { |task| build_task_json task }
    }, status: :ok
  end

  def build_task_json(task)
    {
      id: task.id,
      status: 'recording',
      startAt: task.start_at.rfc3339,
      endAt: task.end_at&.rfc3339 || '0000-00-00T00:00:00Z',
      duration: task.duration,
      taskGroupId: task.task_category.id,
      taskCategoryId: task.task_category.task_group.id
    }
  end
end
