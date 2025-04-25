class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_table :appointments do |t|
      t.date :appointment_date
      t.time :start_time
      t.time :end_time
      t.string :client_name
      t.string :client_email
      t.string :client_phone
      t.decimal :price, precision: 10, scale: 2, null: false
      t.references :service, null: false, foreign_key: true
      t.references :employee, null: true, foreign_key: true
      t.references :customer, null: true, foreign_key: true

      t.timestamps
    end
  end
end
