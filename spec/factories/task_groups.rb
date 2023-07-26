FactoryBot.define do
  factory :task_group do
    ## 現状では TaskGropu の name の取りうる値は固定となっている
    ## また、その name に併せて TaskCategor が自動生成されるようになっている
    ## そのためここではハードコードしているのが、必要になったら改修が必要
    name { '仕事' }
  end
end
