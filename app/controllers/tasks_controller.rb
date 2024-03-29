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
    task = Task.find(params[:id])

    return render_forbidden 'タスクを停止する権限がありません' if task.account.id != @account.id

    begin
      task.make_pending
    rescue TaskStatusError => e
      return render_status_error e
    end

    render json: build_task_json(task), status: :ok
  end

  def start
    task = Task.find(params[:id])

    return render_forbidden 'タスクを再開する権限がありません' if task.account.id != @account.id

    begin
      task.make_recording
    rescue TaskStatusError => e
      return render_status_error e
    end

    render json: build_task_json(task), status: :ok
  end

  def complete
    task = Task.find(params[:id])

    return render_forbidden 'タスクを終了する権限がありません' if task.account.id != @account.id

    begin
      task.make_completed
    rescue TaskStatusError => e
      return render_status_error e
    end

    render json: build_task_json(task), status: :ok
  end

  def recording
    task_ids = Task.recording_tasks_for(@account).pluck(:id)

    render_tasks Task.preload(:task_time_units).where(id: task_ids)
  end

  def pending
    task_ids = Task.pending_tasks_for(@account).pluck(:id)

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

  def render_status_error(error)
    render json: {
      type: 'INVALID_STATUS_TRANSITION',
      title: 'Invalid status transition.',
      detail: error.message
    }, status: :bad_request
  end

  def render_forbidden(error_message)
    render json: {
      type: 'UNAUTHORIZED',
      title: 'Account is not authorized.',
      detail: error_message
    }, status: :forbidden
  end
end
