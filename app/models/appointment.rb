class Appointment < ApplicationRecord

  belongs_to :service
  belongs_to :employee

  scope :for_date, ->(date) { where(appointment_date: date) }

  def self.slots_count_for_date(date)
    available_slots(date).size
  end

end
