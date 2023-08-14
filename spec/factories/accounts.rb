FactoryBot.define do
  factory :account do
    open_id_providers { [FactoryBot.build(:open_id_provider)] }
  end
end
