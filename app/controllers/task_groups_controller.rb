class TaskGroupsController < ApplicationController
  def index
    render_task_groups
  end

  private

  def render_task_groups
    render json: {
      groups: @account.task_groups.as_json
    }
  end
end
