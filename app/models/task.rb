class Task < ApplicationRecord
  belongs_to :task_category
  has_many :task_time_units, dependent: :destroy

  def status
    return :completed if completed
    return :recording if task_time_units.last.end_at.nil?

    :pending
  end

  def make_completed
    latest_task_time_unit = task_time_units.last
    latest_task_time_unit.end_at = Time.zone.now if latest_task_time_unit.end_at.nil?
    transaction do
      latest_task_time_unit.save if latest_task_time_unit.has_changes_to_save?
      update(completed: true)
    end
  end
end
