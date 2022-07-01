class CreateCurrencies < ActiveRecord::Migration[6.1]
  def change
    create_table :currencies do |t|
      t.string :name, null: false, index: { unique: true }
      t.float :rate_to_btc, null: false

      t.timestamps
    end
  end
end
