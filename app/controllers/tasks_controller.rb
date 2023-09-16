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

    render_tasks Task.preload(:task_time_units).where(id: task_ids)
  end

  def pending
    task_ids = Task
               .joins(:task_time_units)
               .where(completed: false)
               .group('tasks.id')
               .having('COUNT(*) = SUM(IF(task_time_units.end_at IS NOT NULL, 1, 0))')
               .pluck(:id)

    render_tasks Task.preload(:task_time_units).where(id: task_ids)
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
      status: task.status,
      startAt: task.start_at&.rfc3339,
      endAt: task.end_at&.rfc3339,
      duration: task.duration,
      taskGroupId: task.task_category.id,
      taskCategoryId: task.task_category.task_group.id
    }
  end
end
