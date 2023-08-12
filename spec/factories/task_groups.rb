FactoryBot.define do
  factory :task_group do
    name { '仕事' }
    account { association :account }
  end
end
