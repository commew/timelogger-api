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

  belongs_to :account

  # API の返り値のキーが categories なのでそれに合わせる
  has_many :categories, class_name: :TaskCategory, dependent: :destroy

  after_create :create_categories

  def as_json
    super(only: %i[id name],
          include: [
            { categories: { only: %i[id name] } }
          ])
  end

  class << self
    def default_tasks
      INIT_DATA.each_key.map do |task_group_name|
        TaskGroup.new(name: task_group_name)
      end
    end
  end

  private

  def create_categories
    INIT_DATA[name].each do |category|
      categories.create(category)
    end
  end
end
