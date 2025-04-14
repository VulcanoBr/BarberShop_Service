class AppointmentMailer < ApplicationMailer
  default from: 'nao-responda@tesouradeouro.com.br' # Ajuste o remetente

  def confirmation_email
    @appointment = params[:appointment] # Pega o agendamento passado via .with()
    @service = @appointment.service
    @employee = @appointment.employee
    @client_name = @appointment.client_name

    mail(to: @appointment.client_email, subject: 'Confirmação de Agendamento - Tesoura De Ouro')
  end
end
