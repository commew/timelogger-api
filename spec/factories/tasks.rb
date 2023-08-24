FactoryBot.define do
  factory :task do
    completed { false }
    task_category { association :task_category }
  end
end
