class CreateServices < ActiveRecord::Migration[7.2]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :duration, default: 60, null: false
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
