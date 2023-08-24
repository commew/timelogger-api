FactoryBot.define do
  factory :task_time_unit do
    start_at { TimeWithZone.now }
    task { association :task }
  end
end
