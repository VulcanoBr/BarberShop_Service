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
      set_selected_date
      set_available_slots
      set_time_employee_combined
      load_services
      set_current_month
      @appointment_form = AppointmentForm.new(@appointment)
    end

    def update
      @appointment_form = AppointmentForm.new(@appointment, appointment_form_params)
      if @appointment_form.save
        redirect_to admin_appointment_path(@appointment), notice: 'Agendamento atualizado com sucesso.'
      else
        setup_edit_variables
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

    def set_selected_date
      @selected_date = if params[:date].present?
                         Date.parse(params[:date])
                       else
                         Date.current
                       end
    rescue ArgumentError
      @selected_date = Date.current
      flash.now[:alert] = "Data inválida, usando data atual"
    end

    def set_available_slots
      @available_slots = AppointmentAvailability.available_slots_for_edit(
        @selected_date,
        @appointment.id
      )
    end

    def set_time_employee_combined
      @time_employee_combined = if @selected_date == @appointment.appointment_date
                                  "#{@appointment.start_time.strftime('%H:%M')}|#{@appointment.employee_id}"
                                else
                                  ""
                                end
    end

    def load_services
      @services = Service.all
    end

    def set_current_month
      if params[:month].present? && params[:year].present?
        @current_month = Date.new(
          params[:year].to_i,
          params[:month].to_i,
          1
        )
      else
        @current_month = Date.current.beginning_of_month
      end
    end

    def setup_edit_variables
      original_date = @appointment.appointment_date_was
      @selected_date = @appointment_form.appointment_date || @appointment.appointment_date
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
    end

    def appointment_form_params
      params.require(:admin_appointment_form).permit(
        :appointment_date,
        :time_employee_combined,
        :service_id,
        :client_name,
        :client_phone,
        :client_email
      )
    end
  end


end
