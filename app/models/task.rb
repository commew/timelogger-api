class Task < ApplicationRecord
  belongs_to :task_category
  has_many :task_time_units, dependent: :destroy
end
