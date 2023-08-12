class TaskGroup < ApplicationRecord
  # 仮りで初期生成される task_group と task_categories
  INIT_DATA_HASH = {
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

  def as_json
    super(only: %i[id name],
          include: [
            { categories: { only: %i[id name] } }
          ])
  end

  def self.init_default_tasks
    INIT_DATA_HASH.each_key.map do |task_group_name|
      task_group = TaskGroup.new(name: task_group_name)
      INIT_DATA_HASH[task_group_name].each do |task_category_name|
        task_group.categories << [TaskCategory.new(name: task_category_name)]
      end
      task_group
    end
  end
end
