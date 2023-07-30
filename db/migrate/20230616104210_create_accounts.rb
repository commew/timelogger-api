class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, default: ''
      t.string :sub, null: false, default: ''
      t.string :provider, null: false, default: ''

      t.timestamps
    end
  end
end
