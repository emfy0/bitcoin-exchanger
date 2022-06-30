class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :txid
      t.string :email, null: false
      t.string :from, null: false
      t.string :to, null: false
      t.string :exchange_rate, null: false
      t.string :exchange_fee, null: false
      t.boolean :status, default: false, null: false

      t.timestamps null: false
    end
  end
end
