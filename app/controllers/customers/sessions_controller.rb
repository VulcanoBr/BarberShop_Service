
module Customers
  class SessionsController < BaseController

    skip_before_action :authenticate_customer!, only: [:new, :create]

    def new
    end

    def create
      customer = Customer.find_by(email: params[:customer][:email])
      if customer&.authenticate(params[:customer][:password])
        if customer.confirmed?
          session[:customer_id] = customer.id
          redirect_to customers_root_path, notice: "Login realizado com sucesso!"
        else
          flash.now[:alert] = "Por favor, confirme seu email antes de fazer login."
          redirect_to customers_login_path
        end
      else
        flash.now[:alert] = "Email ou senha inválidos."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:customer_id] = nil
      redirect_to customers_login_path, notice: "Logout realizado com sucesso!"
    end
  end
end
