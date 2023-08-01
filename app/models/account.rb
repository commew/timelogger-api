class Account < ApplicationRecord
  has_many :open_id_providers, dependent: :destroy
  has_many :task_groups, dependent: :destroy

  validates :open_id_providers, presence: true

  after_create :create_task_groups

  def self.retrieve_by_open_id_provider(sub, provider)
    Account
      .joins(:open_id_providers)
      .where(open_id_providers: { sub:, provider: })
      .first
  end

  def self.create_with_open_id_provider(sub, provider)
    new.tap do |account|
      account.open_id_providers.new(sub:, provider:)
      account.save
    end
  end

  def create_task_groups
    task_groups << TaskGroup.default_tasks
  end
end
