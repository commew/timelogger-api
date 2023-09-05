class TasksController < ApplicationController
  skip_before_action :authenticate
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
    task = Task.where(id: params[:id]).first
    return render_not_founded if task.nil?
    return render_already_completed if task.completed

    task.make_completed
    render_make_task_completed task
  end

  private

  def render_make_task_completed(task)
    task_category_id, task_group_id = Task.joins(:task_category).where(id: task.id)
                                          .pick('task_categories.id', 'task_categories.task_group_id')
    render json: {
      id: task.id,
      status: task.status,
      startAt: task.task_time_units.first.start_at.rfc3339,
      endAt: task.task_time_units.last.end_at.rfc3339,
      taskGroupId: task_group_id,
      taskCategoryId: task_category_id
    }, status: :ok
  end

  def render_not_founded
    render json: {
      type: 'BAD REQUEST',
      title: 'Bad Request',
      invalidParams: [
        {
          id: 'Tasks dosen\'t have the id.'
        }
      ]
    }, status: :bad_request
  end

  def render_already_completed
    render json: {
      type: 'BAD REQUEST',
      title: 'Bad Request',
      invalidParams: [
        {
          id: 'The task is already in completed status.'
        }
      ]
    }, status: :bad_request
  end
end
