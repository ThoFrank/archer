class ApplicationMailer < ActionMailer::Base
  self.delivery_job = MailDeliveryJob

  default from: (ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com")), "X-Mailer": "Archer"
  layout "mailer"
end
