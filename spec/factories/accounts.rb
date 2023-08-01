FactoryBot.define do
  factory :account do
    open_id_providers { [FactoryBot.build(:open_id_provider)] }

    # Account は create されると TaskGroups も自動で作られる
    # TaskGroup 側のテストで困ることがあるので、
    # callback を一時的に skip した状態で Account を作成することもできるようにする
    transient do
      skip_callback { false }
    end

    after(:build) do |account, evaluator|
      account.class.skip_callback(:create, :after, :create_task_groups) if evaluator.skip_callback
    end

    after(:create) do |account, evaluator|
      account.class.set_callback(:create, :after, :create_task_groups) if evaluator.skip_callback
    end
  end
end
