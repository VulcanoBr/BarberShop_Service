module Customers
  class BaseController < ApplicationController

    before_action :authenticate_customer!

    private

    def authenticate_customer!
      redirect_to customers_login_path, alert: "Por favor, faça login para continuar." unless current_customer
    end

  end

end
