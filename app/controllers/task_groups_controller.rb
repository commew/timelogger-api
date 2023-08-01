class TaskGroupsController < ApplicationController
  def index
    render_list
  end

  private

  def render_list
    ## 仮のデータ用意
    ## 本来はリクエストをした account に紐づく TaskGroup の配列を取得する
    account = Account.first || FactoryBot.create(:account)
    render json: {
      groups: account.task_groups.as_json
    }
  end
end
