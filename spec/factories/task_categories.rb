FactoryBot.define do
  factory :task_category do
    name { '会議' }
    task_group { association :task_group, name: '仕事', skip_callback: true }
  end
end
