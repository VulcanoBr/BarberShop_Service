
module Customers
  class RegistrationsController < BaseController

    skip_before_action :authenticate_customer!, only: [:new, :create]

    def new
      @customer = Customer.new
    end

    def create
      @customer = Customer.new(customer_params)

      if @customer.save
        # Enviar email de confirmação
        CustomerMailer.confirmation_email(@customer).deliver_later
        redirect_to customers_login_path, notice: "Cadastro realizado com sucesso! Por favor, confirme seu email."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def customer_params
      params.require(:customer).permit(:name, :email, :phone, :password, :password_confirmation)
    end
  end

end
