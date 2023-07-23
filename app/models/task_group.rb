class TaskGroup < ApplicationRecord
  # 仮りで初期生成される task_group と task_categories
  INIT_DATA = {
    '仕事' => [
      {
        name: '会議'
      },
      {
        name: '資料作成'
      }
    ],
    '学習' => [
      {
        name: 'TOEIC'
      }
    ],
    '趣味' => [
      {
        name: '散歩'
      },
      {
        name: '読書'
      }
    ],
    'グループ未分類' => [
      {
        name: '移動・外出'
      }
    ]
  }.freeze

  ## account table は別 issue で対応のため、今はコメントアウト
  # belongs_to :account
  # validates :account, presence: true
  has_many :task_categories, dependent: :destroy

  after_create :create_categories

  private

  def create_categories
    INIT_DATA[name].each do |category|
      task_categories.create(category)
    end
  end
end
