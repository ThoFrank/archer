class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPServerBusy, Net::OpenTimeout, Net::ReadTimeout,
    wait: :polynomially_longer, attempts: 5
end
