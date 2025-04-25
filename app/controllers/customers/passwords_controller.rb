# app/controllers/customers/passwords_controller.rb
module Customers
  class PasswordsController < BaseController

    def edit
      @customer = current_customer
    end

    def update
      @customer = current_customer

      if @customer.authenticate(params[:customer][:current_password])
        if @customer.update(password_params)
          redirect_to customers_profile_path, notice: "Senha alterada com sucesso!"
        else
          render :edit, status: :unprocessable_entity
        end
      else
        @customer.errors.add(:current_password, "está incorreta")
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.require(:customer).permit(:password, :password_confirmation)
    end
  end
end
