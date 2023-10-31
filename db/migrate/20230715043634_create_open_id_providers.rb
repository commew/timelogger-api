class CreateOpenIdProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :open_id_providers do |t|
      t.references :account

      t.string :sub, null: false, default: ''
      t.string :provider, null: false, default: ''

      t.timestamps
    end
  end
end
