module Customers
  class AppointmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attr_reader :appointment

    # Atributos do formulário
    attribute :appointment_date, :date
    attribute :time_employee_combined, :string
    attribute :service_id, :integer
    attribute :client_name, :string
    attribute :client_phone, :string
    attribute :client_email, :string

    # Validações
    validates :appointment_date, presence: true
    validates :time_employee_combined, presence: true
    validates :service_id, presence: true
    validates :client_name, presence: true
    validates :client_phone, presence: true
    validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    validate :validate_time_employee_format
    validate :validate_slot_availability, if: -> { time_employee_combined.present? && appointment_date.present? }
    validate :validate_date_not_in_past, if: -> { appointment_date.present? }
    validate :validate_not_sunday, if: -> { appointment_date.present? }

    def initialize(appointment, attributes = {})
      @appointment = appointment
      super(attributes.reverse_merge(default_attributes))
    end

    def save
      return false unless valid?

      set_time_and_employee
      set_service_price

      if appointment.update(appointment_params)
        AppointmentAvailability.clear_cache
        send_confirmation_email_if_changed
        true
      else
        errors.merge!(appointment.errors)
        false
      end
    end

    private

    def default_attributes
      {
        appointment_date: appointment.appointment_date,
        time_employee_combined: "#{appointment.start_time.strftime('%H:%M')}|#{appointment.employee_id}",
        service_id: appointment.service_id,
        client_name: appointment.client_name,
        client_phone: appointment.client_phone,
        client_email: appointment.client_email
      }
    end

    def appointment_params
      {
        appointment_date: appointment_date,
        start_time: @parsed_time,
        employee_id: @employee_id,
        service_id: service_id,
        client_name: client_name,
        client_phone: client_phone,
        client_email: client_email,
        price: @service_price
      }
    end

    def set_time_and_employee
      return if time_employee_combined.blank?

      time_str, employee_id = time_employee_combined.split('|')
      hour, minute = time_str.split(':').map(&:to_i)

      @parsed_time = appointment_date.to_time.change(hour: hour, min: minute)
      @employee_id = employee_id
    end

    def set_service_price
      service = Service.find_by(id: service_id)
      @service_price = service&.price
    end

    def send_confirmation_email_if_changed
      if appointment.saved_change_to_start_time? ||
         appointment.saved_change_to_appointment_date? ||
         appointment.saved_change_to_service_id?
        AppointmentMailer.with(appointment: appointment).confirmation_email.deliver_now
      end
    end

    def validate_time_employee_format
      return if time_employee_combined.blank?

      unless time_employee_combined.match?(/\A\d{2}:\d{2}\|\d+\z/)
        errors.add(:time_employee_combined, :invalid_format)
      end
    end

    def validate_slot_availability
      return if time_employee_combined.blank? || appointment_date.blank?

      time_str, employee_id = time_employee_combined.split('|')

      unless AppointmentAvailability.slot_available?(appointment_date, time_str, employee_id) ||
             (appointment_date == appointment.appointment_date &&
              time_str == appointment.start_time.strftime('%H:%M') &&
              employee_id.to_i == appointment.employee_id)
        errors.add(:time_employee_combined, :slot_not_available)
      end
    end

    def validate_date_not_in_past
      if appointment_date < Date.current
        errors.add(:appointment_date, :in_past)
      end
    end

    def validate_not_sunday
      if appointment_date.sunday?
        errors.add(:appointment_date, :sunday_not_allowed)
      end
    end
  end
end
