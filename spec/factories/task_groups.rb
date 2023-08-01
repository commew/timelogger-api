FactoryBot.define do
  factory :task_group do
    name { '仕事' }
    account { association :account, skip_callback: true }
  end
end
