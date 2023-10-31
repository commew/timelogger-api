# 呼ぶときは FactoryBot.build :open_id_provider とすること (インスタンス生成だけ)
# Account との関連なしに DB 保存しようとするとエラーが発生する
FactoryBot.define do
  factory :open_id_provider do
    sub { SecureRandom.uuid }
    provider { 'google' }
  end
end
