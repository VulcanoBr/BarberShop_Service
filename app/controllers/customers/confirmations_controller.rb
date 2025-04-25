
module Customers
  class ConfirmationsController < BaseController

    skip_before_action :authenticate_customer!

    def confirm
      @customer = Customer.find_by(confirmation_token: params[:token])

      if @customer
        @customer.confirm!
        redirect_to customers_login_path, notice: "Email confirmado com sucesso! Agora você pode fazer login."
      else
        redirect_to customers_login_path, alert: "Link de confirmação inválido."
      end
    end
  end
end
