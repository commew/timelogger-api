class AddReferenceAccountToTaskGroups < ActiveRecord::Migration[7.0]
  def change
    change_table :task_groups do |t|
      t.references :account, null: false
    end
  end
end
