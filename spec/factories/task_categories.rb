FactoryBot.define do
  factory :task_category do
    name { '会議' }
    task_group { association :task_group, name: '仕事' }
  end
end
