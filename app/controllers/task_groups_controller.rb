class TaskGroupsController < ApplicationController
  def index
    render_task_groups
  end

  private

  def render_task_groups
    render json: {
      groups: @account.task_groups.order(:id, 'task_categories.id' => :asc).eager_load(:categories).as_json
    }
  end
end
