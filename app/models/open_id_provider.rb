class OpenIdProvider < ApplicationRecord
  belongs_to :account

  validates :sub, presence: true
  validates :provider, presence: true
end
