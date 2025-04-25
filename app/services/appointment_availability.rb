# app/services/appointment_availability.rb
class AppointmentAvailability

  OPENING_HOUR = 9 # 9:00
  CLOSING_HOUR = 18 # 18:00
  SERVICE_DURATION = 60 # minutos

  def self.has_slots_for_date?(date)
    date = date.is_a?(String) ? Date.parse(date) : date
    return false if date.nil? || date.sunday? || date < Date.current

    generate_slots_for_date(date).present?
  end

  def self.generate_slots_for_date(date)
    date = date.is_a?(String) ? Date.parse(date) : date
    return [] if date.nil? || date.sunday? || date < Date.current

    @available_slots_cache ||= {}
    return @available_slots_cache[date] if @available_slots_cache[date]

    employees = Employee.active

    booked_slots = Appointment.where(appointment_date: date)
                   .pluck(:start_time, :employee_id)
                   .map { |time, emp_id| ["#{time.strftime('%H:%M')}", emp_id.to_s] }

    all_slots = []

    employees.each do |employee|
      (OPENING_HOUR...CLOSING_HOUR).each do |hour|
        # Para horários de 60 minutos, só precisamos verificar horas inteiras
        time_str = format('%02d:%02d', hour, 0)

        if date == Date.current
          current_hour = Time.current.hour + 1
          current_minute = Time.current.min
          next if hour < current_hour || (hour == current_hour && current_minute > 0)
        end

        unless booked_slots.include?([time_str, employee.id.to_s])
          all_slots << [
            "#{time_str} - #{employee.surname || employee.surname}",
            "#{time_str}|#{employee.id}"
          ]
        end
      end
    end

    @available_slots_cache[date] = all_slots.sort_by { |slot| slot[0] }
  end

  def self.slot_available?(date, time_str, employee_id)
    return false if date.nil? || time_str.blank? || employee_id.blank?

    hour, minute = time_str.split(':').map(&:to_i)
    time = date.to_time.change(hour: hour, min: minute)

    # Verifica se já existe um agendamento para este horário e funcionário
    !Appointment.exists?(appointment_date: date, start_time: time, employee_id: employee_id)
  end

  def self.clear_cache
    @available_slots_cache = nil
  end

  def self.available_slots_for_edit(date, appointment_id)
    all_slots = generate_slots_for_date(date)   #available_slots(date)

    current_appointment = Appointment.find(appointment_id)

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

end
