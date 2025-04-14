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

  def self.available_slots(date)

    selected_date = date.is_a?(Date) ? date : Date.parse(date.to_s)

    start_hour = WORKING_HOURS_START

    if selected_date == Date.current
      current_hour = Time.zone.now.hour
      effective_start_hour = if Time.zone.now.min > 0
                              current_hour + 1
                            else
                              current_hour
                            end
      start_hour = [WORKING_HOURS_START, effective_start_hour].max
    end

    start_hour = [start_hour, WORKING_HOURS_END].min

    employees = Employee.where(active: true)

    available_slots = []

    employees.each do |employee|
      # Busca os horários já reservados para este funcionário nesta data
      booked_times = for_date(selected_date)
                      .where(employee_id: employee.id)
                      .pluck(:start_time)
                      .map { |t| t.strftime('%H:%M') }

      all_possible_slots = (start_hour...WORKING_HOURS_END).map do |hour|
        Time.zone.local(selected_date.year, selected_date.month, selected_date.day, hour).strftime('%H:%M')
      end

      available = all_possible_slots - booked_times

      available.each do |time_str|
        display_text = "#{time_str} - #{employee.surname}"
        value = "#{time_str}|#{employee.id}"
        available_slots << [display_text, value]
      end
    end

    available_slots.sort_by { |slot| slot[0] }
  end

  def self.available_slots_for_edit(date, appointment_id)
    all_slots = available_slots(date)

    current_appointment = find(appointment_id)

    if date == current_appointment.appointment_date

      current_time = current_appointment.start_time.strftime('%H:%M')
      current_employee = current_appointment.employee

      current_slot_text = "#{current_time} - #{current_employee.surname}"
      current_slot_value = "#{current_time}|#{current_employee.id}"

      unless all_slots.any? { |slot| slot[1] == current_slot_value }
        all_slots << [current_slot_text, current_slot_value]
      end

      all_slots.sort_by { |slot| slot[0] }
    end
    all_slots
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
