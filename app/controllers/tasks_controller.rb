class TasksController < ApplicationController
  # XXX taskGroupId, statusは不要なのでまったく見ていない
  def create
    task_category = TaskCategory.find_by(id: task_params['taskCategoryId'])

    if (task = Task.start_recording(task_category, Time.zone.now, @account)).invalid?
      return render_validation_errored task.errors
    end

    render json: build_task_json(task), status: :created
  end

  def stop
    render json: {}, status: :ok
  end

  def complete
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

  def render_validation_errored(errors)
    render json: {
      type: 'UNPROCESSABLE_ENTITY',
      title: 'Unprocessable Entity.',
      invalidParams: errors.map do |error|
        {
          name: error.attribute,
          reason: error.message
        }
      end
    }, status: :unprocessable_entity
  end
end
