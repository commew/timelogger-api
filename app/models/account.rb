class Account < ApplicationRecord
  validates :sub, presence: true
  validates :provider, presence: true
end
