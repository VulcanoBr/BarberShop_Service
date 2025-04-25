
# app/mailers/customer_mailer.rb
class CustomerMailer < ApplicationMailer
  def confirmation_email(customer)
    @customer = customer
    @confirmation_url = customers_confirm_url(token: @customer.confirmation_token)

    mail(to: @customer.email, subject: "Confirme seu cadastro")
  end

  def password_reset_email(customer)
    @customer = customer
    @reset_url = customers_password_reset_url(@customer.reset_password_token)

    mail(to: @customer.email, subject: "Instruções para redefinir sua senha")
  end
end
