class CreateTaskGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :task_groups do |t|
      t.references :account, null: false
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
