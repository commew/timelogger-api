class Task < ApplicationRecord
  STATUS = {
    recording: :recording,
    pending: :pending,
    completed: :completed
  }.freeze

  TASK_CATEGORY_ACCOUNT_ERROR_MESSAGE =
    'task_category に関連している account と、task を作成しようとした account が一致しません。'.freeze

  belongs_to :task_category
  has_many :task_time_units, dependent: :destroy

  attr_accessor :account_start_by

  validates :task_time_units, presence: true
  validate :verify_account, on: :create

  def verify_account
    # task_categoryがない場合はそちらでエラーが出るので、こちらでは無視してOK.
    return unless task_category

    return if task_category.task_group.account_id == @account_start_by&.id

    errors.add(:task_category, TASK_CATEGORY_ACCOUNT_ERROR_MESSAGE)
  end

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
    def start_recording(task_category, start_at, account)
      new.tap do |task|
        task.account_start_by = account
        task.task_category = task_category
        task.task_time_units << TaskTimeUnit.new(start_at:)
        task.save
      end
    end
  end
end
