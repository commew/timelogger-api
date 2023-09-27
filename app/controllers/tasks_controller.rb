class TasksController < ApplicationController
  def create
    # TODO: カテゴリがない場合の処理
    task_category = TaskCategory.find(task_params['taskCategoryId'])

    task = Task.start_recording(task_category, Time.zone.now, @account)

    render json: build_task_json(task), status: :created
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

  def task_params
    params.permit(:taskGroupId, :taskCategoryId, :status)
  end

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
