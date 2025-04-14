class AppointmentsController < ApplicationController

  def new
    @appointment = Appointment.new(appointment_date: params[:date]) # Pega data do parametro se existir

    @selected_date = if params[:date].present?
      Date.parse(params[:date])
    else
      today = Date.current
      if today.sunday?
        today + 1.day
      else
        today
      end
    end
    @available_slots = Appointment.available_slots(@selected_date)
    @services = Service.all

    if params[:month].present? && params[:year].present?
      @current_month = Date.new(params[:year].to_i, params[:month].to_i, 1)
    else
      @current_month = Date.current.beginning_of_month
    end
  end

  def create
    @appointment = Appointment.new(appointment_params)
    puts("params = #{appointment_params.inspect}")
    service = Service.find_by(id: params[:appointment][:service_id])
    @appointment.price = service.price

    if @appointment.appointment_date && params[:appointment][:time_employee_combined].present?
      time_str, employee_id = params[:appointment][:time_employee_combined].split('|')
      hour, minute = time_str.split(':').map(&:to_i)
      @appointment.start_time = @appointment.appointment_date.to_time.change(hour: hour, min: minute)
      @appointment.employee_id = employee_id
    end

    if @appointment.save
      AppointmentMailer.with(appointment: @appointment).confirmation_email.deliver_now
      redirect_to appointment_path(@appointment), notice: 'Agendamento realizado com sucesso!'
    else
      @selected_date = @appointment.appointment_date || Date.current
      @available_slots = Appointment.available_slots(@selected_date)
      @services = Service.all
      @current_month = @selected_date.beginning_of_month

      flash.now[:alert] = "Erro ao agendar. Verifique os campos."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :appointment_date,
      :time_employee_combined,
      :client_name,
      :client_phone,
      :client_email,
      :service_id
    )
  end
end
