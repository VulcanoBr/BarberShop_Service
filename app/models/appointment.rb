class Appointment < ApplicationRecord

  belongs_to :service
  belongs_to :employee

  attr_accessor :time_employee_combined

  validates :appointment_date, presence: true
  validates :start_time, presence: true
  validates :client_name, presence: true
  validates :client_phone, presence: true # Adicionar validação de formato se desejar
  validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :service_id, presence: true
  validates :employee_id, presence: true

  validate :time_within_working_hours
  validate :validate_time_employee_combined, on: [:create, :update]

  WORKING_HOURS_START = 8
  WORKING_HOURS_END = 18 # O último slot começa às 17h

  scope :for_date, ->(date) { where(appointment_date: date) }

  def self.slots_count_for_date(date)
    available_slots(date).size
  end

  after_create :clear_available_slots_cache
  after_destroy :clear_available_slots_cache

  def clear_available_slots_cache
    @available_slots_cache = nil
  end

  private

  def validate_time_employee_combined
    if (start_time.blank? || employee_id.blank?) || time_employee_combined.blank?
      errors.add(:time_employee_combined, "deve ser selecionado")
    end
  end

  def time_within_working_hours
    return if start_time.blank?

    if start_time.hour < WORKING_HOURS_START || start_time.hour >= WORKING_HOURS_END
      errors.add(:start_time, "deve ser entre #{WORKING_HOURS_START}:00 e #{WORKING_HOURS_END - 1}:00")
    end

    unless start_time.min == 0
      errors.add(:start_time, "deve ser em horas cheias (ex: 09:00, 10:00).")
    end
  end

end
