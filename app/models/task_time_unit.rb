class TaskTimeUnit < ApplicationRecord
  belongs_to :task

  validates :start_at, presence: true
end
