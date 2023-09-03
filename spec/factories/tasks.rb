FactoryBot.define do
  factory :task do
    completed { false }
    task_category { association :task_category }
    task_time_units { [FactoryBot.build(:task_time_unit)] }
  end
end
