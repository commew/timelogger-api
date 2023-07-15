class RemoveNameFromAccounts < ActiveRecord::Migration[7.0]
  def change
    remove_column :accounts, :name, :string
  end
end
