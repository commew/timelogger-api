class Task < ApplicationRecord
  belongs_to :task_category
  has_many :task_time_units, dependent: :destroy

  def status
    return :completed if completed
    return :recording if task_time_units.last.end_at.nil?

    :pending
  end

  def start_at
    task.task_time_units.first.start_at
  end

  def end_at
    task.task_time_units.last.end_at
  end

  def duration
    duration_seconds = 0
    task_time_units.each do |unit|
      next if unit.end_at.nil?

      duration_seconds += unit.end_at - unit.start_at
    end
    duration_seconds
  end

  def make_pending(end_at = nil)
    latest_time_unit = task_time_units.last
    raise 'Task is already stoped.' unless status == :recording

    end_at = Time.zone.now if end_at.nil?
    transaction do
      latest_time_unit.update end_at:
    end
  end

  def make_recording(start_at = nil)
    raise 'Task is already recording.' unless status == :pending

    start_at = Time.zone.now if start_at.nil?
    transaction do
      task_time_units << TaskTimeUnit.new(start_at:)
    end
  end

  def make_completed(end_at = nil)
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
