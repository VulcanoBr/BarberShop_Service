class Appointment < ApplicationRecord

  belongs_to :service
  belongs_to :employee
  belongs_to :customer

  scope :for_date, ->(date) { where(appointment_date: date) }

  # Scope para buscar agendamentos de um cliente específico
  scope :for_customer, ->(customer) { where(customer_id: customer.id) if customer }

  # Scope para buscar agendamentos futuros
  scope :future, -> { where("appointment_date > ?", Date.current) }

  # Scope para ordenar por data (opcional, mas útil)
  scope :sorted_by_date, -> { order(:appointment_date) }


  def self.slots_count_for_date(date)
    available_slots(date).size
  end

end
