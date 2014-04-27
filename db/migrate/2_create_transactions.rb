class CreateTransactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.datetime :created
      t.float :amount
      t.integer :user_id
      t.string :thash
    end

    add_index :transactions, :thash
  end
  
  def down
    drop_table :transactions
  end
end
