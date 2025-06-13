class ApplicationMailer < ActionMailer::Base
  default from: (ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"))
  layout "mailer"
end
