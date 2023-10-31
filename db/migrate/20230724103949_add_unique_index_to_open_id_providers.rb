class AddUniqueIndexToOpenIdProviders < ActiveRecord::Migration[7.0]
  def change
    add_index :open_id_providers, %w[sub provider], unique: true
  end
end
