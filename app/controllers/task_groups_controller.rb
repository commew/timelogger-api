class TaskGroupsController < ApplicationController
  def index
    render_list
  end

  private

  def render_list
    ## 仮のデータ用意
    ## 本来は account に紐づく TaskGroup の配列を取得する
    task_group = (TaskGroup.first.presence || TaskGroup.create(name: '仕事'))
    render json: {
      groups: [task_group.as_json]
    }
  end
end
