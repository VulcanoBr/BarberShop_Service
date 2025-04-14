module Admin

  class DashboardController < AdminController

    include Pagy::Backend

    def index
     # @today_appointments = Appointment.where('appointment_date = ?', Date.today).order(:start_time)
      today_scope = Appointment.includes(:employee, :service)
                              .where('appointment_date = ?', Date.today)
                              .order(:start_time)

      @pagy_today, @today_appointments = pagy(today_scope, page_param: :page_today, limit: 6)
      # @upcoming_appointments = Appointment.where('appointment_date > ?', Date.today).includes(:service).order(:appointment_date, :start_time).limit(10)
      upcoming_scope = Appointment.includes(:employee, :service)
                                .where('appointment_date > ?', Date.today)
                                .order(:appointment_date, :start_time)
      @pagy_upcoming, @upcoming_appointments = pagy(upcoming_scope, page_param: :page_upcoming, limit: 6)
      @services_count = Service.count
      @appointments_count = Appointment.count
      @month_appointments = Appointment.where(appointment_date: Date.today.beginning_of_month..Date.today.end_of_month).count
    end
  end

end
