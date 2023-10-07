class TasksController < ApplicationController
  def create
    # TODO: カテゴリがない場合の処理
    task_category = TaskCategory.find(task_params['taskCategoryId'])

    task = Task.start_recording(task_category, Time.zone.now, @account)

    render json: build_task_json(task), status: :created
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
    task_ids = Task
               .joins(:task_time_units)
               .joins(task_category: :task_group)
               .where(completed: false)
               .merge(TaskGroup.where(account_id: @account))
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

  def task_params
    params.permit(:taskGroupId, :taskCategoryId, :status)
  end

  def render_tasks(tasks)
    render json: {
      tasks: tasks.map { |task| build_task_json task }
    }, status: :ok
  end

  def build_task_json(task)
    {
      id: task.id,
      status: task.status,
      startAt: task.start_at.rfc3339,
      endAt: task.end_at&.rfc3339 || '0000-00-00T00:00:00Z',
      duration: task.duration,
      taskGroupId: task.task_category.task_group.id,
      taskCategoryId: task.task_category.id
    }
  end
end
