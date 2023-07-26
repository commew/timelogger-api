class TaskCategory < ApplicationRecord
  belongs_to :task_group

  def as_json
    super(only: %i[id name])
  end
end
