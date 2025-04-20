class AppointmentsController < ApplicationController

  def new

    @appointment_form = AppointmentForm.new(appointment_date: params[:date])

    @selected_date = selected_date(params[:date])

    @available_slots = AppointmentAvailability.generate_slots_for_date(@selected_date)

    @services = Service.all

    @current_month = current_month(params[:month], params[:year])

  end

  def create
    @appointment_form = AppointmentForm.new(appointment_form_params)

    if (appointment = @appointment_form.save)
      redirect_to appointment_path(appointment),
                  notice: 'Agendamento realizado com sucesso!'
    else
      setup_edit_variables
      flash.now[:alert] = "Erro ao agendar. Verifique os campos."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def selected_date(date_param)
    if date_param.present?
      Date.parse(date_param)
    else
      today = Date.current
      today.sunday? ? today + 1.day : today
    end
  end

  def current_month(month_param, year_param)
    if month_param.present? && year_param.present?
      Date.new(year_param.to_i, month_param.to_i, 1)
    else
      Date.current.beginning_of_month
    end
  end

  def setup_edit_variables
    date_from_form = @appointment_form.appointment_date
    @selected_date = date_from_form.is_a?(String) ? Date.parse(date_from_form) : (date_from_form || Date.current)
    @available_slots = AppointmentAvailability.generate_slots_for_date(@selected_date)
    @services = Service.all
    @current_month = current_month(params[:month], params[:year])
  end

  def appointment_form_params
    params.require(:appointment_form).permit(
      :appointment_date,
      :time_employee_combined,
      :client_name,
      :client_phone,
      :client_email,
      :service_id
    )
  end
end
