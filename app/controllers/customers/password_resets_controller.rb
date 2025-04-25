# app/controllers/customers/password_resets_controller.rb
module Customers
  class PasswordResetsController < BaseController

    skip_before_action :authenticate_customer!

    def new
    end

    def create
      @customer = Customer.find_by(email: params[:customer][:email])

      if @customer
        @customer.generate_password_reset_token!
        # Enviar email de reset de senha
        CustomerMailer.password_reset_email(@customer).deliver_later
        redirect_to customers_login_path, notice: "Se o email estiver cadastrado, você receberá instruções para redefinir sua senha."
      else
        flash.now[:alert] = "Email inválido ou não cadastrado."
        render :new, status: :unprocessable_entity
      end


    end

    def edit
      @customer = Customer.find_by(reset_password_token: params[:token])

      if @customer.nil? || @customer.password_reset_expired?
        redirect_to customers_forgot_password_path, alert: "Link inválido ou expirado. Por favor, tente novamente."
      end
    end

    def update
      @customer = Customer.find_by(reset_password_token: params[:token])

      if @customer.nil? || @customer.password_reset_expired?
        redirect_to customers_forgot_password_path, alert: "Link inválido ou expirado. Por favor, tente novamente."
        return
      end

      if @customer.update(password_params.merge(reset_password_token: nil, reset_password_sent_at: nil))
        redirect_to customers_login_path, notice: "Senha alterada com sucesso! Agora você pode fazer login."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.require(:customer).permit(:password, :password_confirmation)
    end
  end
end
