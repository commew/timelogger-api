FactoryBot.define do
  factory :task do
    completed { false }
    task_category { association :task_category }
    task_time_units { [FactoryBot.build(:task_time_unit)] }
    account_start_by { task_category.task_group.account }
  end
end
