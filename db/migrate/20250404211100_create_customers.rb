class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :password_digest
      t.boolean :email_confirmed, default: false
      t.string :confirmation_token
      t.string :remember_token
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
    end
    add_index :customers, :email, unique: true
    add_index :customers, :confirmation_token, unique: true
    add_index :customers, :reset_password_token, unique: true
  end
end
