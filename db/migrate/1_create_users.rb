class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :phash
      t.string :salt
      t.float :balance
      t.string :token
      t.datetime :token_expires
    end

    add_index :users, :token
  end

  def down
    drop_table :users
  end
end
