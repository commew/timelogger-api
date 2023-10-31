class RemoveSubAndProviderFromAccounts < ActiveRecord::Migration[7.0]
  def change
    remove_column :accounts, :sub, :string
    remove_column :accounts, :provider, :string
  end
end
