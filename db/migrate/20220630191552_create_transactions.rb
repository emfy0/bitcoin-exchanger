class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :txid
      t.string :email, null: false
      t.string :wallet_address, null: false
      t.string :recipient_address, null: false
      t.string :income_cur_code, null: false
      t.string :outcome_cur_code, null: false
      t.float :income_in_btc, null: false
      t.float :outcome_in_btc, null: false
      t.float :income_rate_to_btc, null: false
      t.float :outcome_rate_to_btc, null: false
      t.float :network_fee, null: false
      t.boolean :status, default: false, null: false

      t.timestamps null: false
    end
  end
end
