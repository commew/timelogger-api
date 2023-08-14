class CreateTaskGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :task_groups do |t|
      # accounts table は別 issue の範囲なので一旦コメントアウト対応
      # t.references :account, null: false
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
