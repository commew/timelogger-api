# 呼ぶときは FactoryBot.build :task_time_unit とすること (インスタンス生成だけ)
# Task との関連なしに DB 保存しようとするとエラーが発生する
# task のコンポジット
FactoryBot.define do
  factory :task_time_unit do
    start_at { Time.zone.now }
    end_at { nil }
  end
end
