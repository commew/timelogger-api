class TasksController < ApplicationController
  skip_before_action :authenticate
  def create
    render json: {}, status: :ok
  end

  def recording
    tasks = []
    render json: { tasks: }, status: :ok
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
end
