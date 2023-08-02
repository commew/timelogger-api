FactoryBot.define do
  factory :task_group do
    name { '仕事' }
    account { association :account, skip_callback: true }

    # TaskGroup は create されると TaskCategory も自動で作られる
    # TaskCategory 側のテストで困ることがあるので、
    # callback を一時的に skip した状態で TaskGroup を作成することもできるようにする
    transient do
      skip_callback { false }
    end

    after(:build) do |task_group, evaluator|
      task_group.class.skip_callback(:create, :after, :create_categories) if evaluator.skip_callback
    end

    after(:create) do |task_group, evaluator|
      task_group.class.set_callback(:create, :after, :create_categories) if evaluator.skip_callback
    end
  end
end
