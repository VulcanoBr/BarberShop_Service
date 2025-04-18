module Admin
  class AppointmentsController < AdminController

    include Pagy::Backend

    before_action :set_appointment, only: [:show, :edit, :update, :destroy]

    def index
      appointments_scope = Appointment.includes(:service)

      if params[:search].present?
        if params[:search][:appointment_date].present?
          date = Date.parse(params[:search][:appointment_date]) rescue nil
          appointments_scope = appointments_scope.where(appointment_date: date) if date
        end

        if params[:search][:client_name].present?
          name_query = "%#{params[:search][:client_name]}%"
          appointments_scope = appointments_scope.where("client_name ILIKE ?", name_query)
        end

        if !params[:search][:appointment_date].present? && !params[:search][:client_name].present?
          appointments_scope = appointments_scope.where('appointment_date >= ?', Date.today)
        end
      else
        appointments_scope = appointments_scope.where('appointment_date >= ?', Date.today)
      end

      appointments_scope = appointments_scope.order(appointment_date: :desc, start_time: :desc)

      @pagy_appointments, @appointments = pagy(appointments_scope, page_param: :page_appointments, limit: 10)
    end

    def edit
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      @available_slots = AppointmentAvailability.available_slots_for_edit(@selected_date, @appointment.id)
      if @selected_date == @appointment.appointment_date
        @time_employee_combined = "#{@appointment.start_time.strftime('%H:%M')}|#{@appointment.employee_id}"
      else
        @time_employee_combined = ""
      end
      @services = Service.all
      if params[:month].present? && params[:year].present?
        @current_month = Date.new(params[:year].to_i, params[:month].to_i, 1)
      else
        @current_month = Date.current.beginning_of_month
      end
    end

    def update
      service = Service.find_by(id: params[:appointment][:service_id])
      @appointment.price = service.price

      if params[:appointment][:appointment_date] && params[:appointment][:time_employee_combined].present?
        time_str, employee_id = params[:appointment][:time_employee_combined].split('|')
        hour, minute = time_str.split(':').map(&:to_i)
        params[:appointment][:start_time] =
          Date.parse(params[:appointment][:appointment_date]).to_time.change(hour: hour, min: minute)
        params[:appointment][:employee_id] = employee_id
      end
      if @appointment.update(appointment_params)
        AppointmentAvailability.clear_cache
        if @appointment.saved_change_to_start_time? || @appointment.saved_change_to_appointment_date?  ||
          @appointment.saved_change_to_service_id?
          AppointmentMailer.with(appointment: @appointment).confirmation_email.deliver_now
        end
        redirect_to admin_appointment_path(@appointment), notice: 'Agendamento atualizado com sucesso.'
      else
        original_date = @appointment.appointment_date_was
        @selected_date = params[:date].present? ? Date.parse(params[:date]) : @appointment.appointment_date
        @available_slots = AppointmentAvailability.available_slots_for_edit(@selected_date, @appointment.id)

        if @selected_date == original_date
          @time_employee_combined = "#{@appointment.start_time.strftime('%H:%M')}|#{@appointment.employee_id}"
        else
          @time_employee_combined = ""
        end
        @services = Service.all
        if params[:month].present? && params[:year].present?
          @current_month = Date.new(params[:year].to_i, params[:month].to_i, 1)
        else
          @current_month = Date.current.beginning_of_month
        end
        render :edit, status: :unprocessable_entity
      end
    end

    def show
    end

    def destroy
      if @appointment.destroy
        AppointmentAvailability.clear_cache
        redirect_to admin_appointments_url, notice: 'Agendamento excluído com sucesso.'
      else
        redirect_to admin_appointments_url, alert: 'Não foi possível excluir o agendamento.'
      end
    end

    private

    def set_appointment
      @appointment = Appointment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_appointments_path, alert: "Agendamento não encontrado."
      end

      def appointment_params
        params.require(:appointment).permit(
          :appointment_date,
          :start_time,
          :time_employee_combined,
          :service_id,
          :employee_id
        )
      end
  end

end
