class AppointmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  # Atributos do formulário
  attr_accessor :appointment_date, :time_employee_combined, :client_name,
                :client_phone, :client_email, :service_id, :user

  # Validações
  validates :appointment_date, presence: true
  validates :time_employee_combined, presence: true
  validates :client_name, presence: true
  validates :client_phone, presence: true
  validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :service_id, presence: true

  validate :time_within_working_hours
  # validate :slot_availability

  def save
    return false unless valid?

    # Processa os dados e cria o agendamento
    process_time_employee
    find_service

    @appointment = Appointment.new(
      appointment_date: appointment_date,
      start_time: @start_time,
      employee_id: @employee_id,
      client_name: client_name,
      client_phone: client_phone,
      client_email: client_email,
      service_id: service_id,
      price: @service_price
    )

    if @appointment.save
      AppointmentAvailability.clear_cache
      send_confirmation_email(@appointment)
      @appointment
    else
      errors.merge!(appointment.errors)
      false
    end
  end

  private

  def time_within_working_hours
    return if time_employee_combined.blank?

    time_str, _ = time_employee_combined.split('|')
    hour = time_str.split(':').first.to_i

    unless (9..17).cover?(hour)
      errors.add(:time_employee_combined, "deve estar dentro do horário comercial (9h às 17h)")
    end
  end

  def slot_availability
    return if time_employee_combined.blank? || appointment_date.blank?

    time_str, employee_id = time_employee_combined.split('|')
    unless Appointment.slot_available?(appointment_date, time_str, employee_id)
      errors.add(:time_employee_combined, "horário já está reservado")
    end
  end

  def process_time_employee
    return if time_employee_combined.blank?

    time_str, employee_id = time_employee_combined.split('|')
    hour, minute = time_str.split(':').map(&:to_i)

    @start_time = appointment_date.to_time.change(hour: hour, min: minute)
    @employee_id = employee_id
  end

  def find_service
    service = Service.find_by(id: service_id)
    @service_price = service&.price || 0
  end

  def send_confirmation_email(appointment)
    AppointmentMailer.with(appointment: appointment).confirmation_email.deliver_now
  end
end
