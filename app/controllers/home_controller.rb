class HomeController < ApplicationController

  def index
    @services = Service.order("RANDOM()").limit(3)
    @appointment = Appointment.new
    @date = params[:date] || Date.today
  end

  def list_services
    @services_list = Service.order(:name)
  end
end
