class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :surname
      t.boolean :active

      t.timestamps
    end
  end
end
