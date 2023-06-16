class Account < ApplicationRecord
  validates :name, presence: false
  validates :sub, presence: true
  validates :provider, presence: true
end
