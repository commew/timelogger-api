class Account < ApplicationRecord
  has_many :open_id_providers, dependent: :destroy
  has_many :task_groups, dependent: :destroy

  validates :open_id_providers, presence: true

  def self.retrieve_by_open_id_provider(sub:, provider:)
    Account
      .joins(:open_id_providers)
      .where(open_id_providers: { sub:, provider: })
      .first
  end

  def self.create_with_open_id_provider(sub, provider)
    new.tap do |account|
      account.open_id_providers.new(sub:, provider:)
      account.init_default_task_groups
      account.save
    end
  end

  # private

  def init_default_task_groups
    task_groups << TaskGroup.init_default_tasks
  end
end
