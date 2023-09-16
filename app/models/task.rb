class Task < ApplicationRecord
  STATUS = {
    recording: :recording,
    pending: :pending,
    completed: :completed
  }.freeze

  belongs_to :task_category
  has_many :task_time_units, dependent: :destroy

  def status
    return STATUS[:completed] if completed
    return STATUS[:recording] if end_at.nil?

    STATUS[:pending]
  end

  def start_at
    task_time_units.first.start_at
  end

  def end_at
    task_time_units.last.end_at
  end

  def duration
    task_time_units.sum do |unit|
      unit.end_at.nil? ? 0 : unit.end_at - unit.start_at
    end
  end

  def make_pending(end_at = nil)
    current_status = status
    raise "Task status is #{current_status}, could not make status pending." unless current_status == STATUS[:recording]

    end_at = Time.zone.now if end_at.nil?
    transaction do
      task_time_units.last.update end_at:
    end
  end

  def make_recording(start_at = nil)
    current_status = status
    raise "Task status is #{current_status}, could not make status recording." unless current_status == STATUS[:pending]

    start_at = Time.zone.now if start_at.nil?
    transaction do
      task_time_units << TaskTimeUnit.new(start_at:)
    end
  end

  def make_completed(end_at = nil)
    raise 'Task status is already completed.' if status == STATUS[:completed]

    end_at = Time.zone.now if end_at.nil?
    latest_time_unit = task_time_units.last
    latest_time_unit.end_at = end_at if latest_time_unit.end_at.nil?
    transaction do
      latest_time_unit.save if latest_time_unit.has_changes_to_save?
      update(completed: true)
    end
  end

  class << self
    def start_recording(task_category, start_at)
      new.tap do |task|
        task.task_category = task_category
        task.task_time_units << TaskTimeUnit.new(start_at:)
        task.save
      end
    end
  end
end
