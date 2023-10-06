FactoryBot.define do
  factory :account do
    transient do
      open_id_provider { build(:open_id_provider) }
    end

    after(:build) do |account, evaluator|
      account.open_id_providers << evaluator.open_id_provider
    end
  end
end
