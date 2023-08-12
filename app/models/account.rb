class Account < ApplicationRecord
  has_many :open_id_providers, dependent: :destroy

  validates :open_id_providers, presence: true

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
end
