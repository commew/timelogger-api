class TaskCategory < ApplicationRecord
  belongs_to :task_group, dependent: :destroy
end
