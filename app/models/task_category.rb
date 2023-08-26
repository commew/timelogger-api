class TaskCategory < ApplicationRecord
  belongs_to :task_group
  has_many :task, dependent: :destroy
end
