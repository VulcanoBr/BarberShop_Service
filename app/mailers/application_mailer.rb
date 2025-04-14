class ApplicationMailer < ActionMailer::Base

  helper ApplicationHelper

  default from: "from@tesouradeouro.com.br"
  layout "mailer"
end
