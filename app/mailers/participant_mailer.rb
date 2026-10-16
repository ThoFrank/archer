class ParticipantMailer < ApplicationMailer
  def registration_confirmation(registration)
    @registration = registration
    mail(to: @registration.email, bcc: ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"), subject: (t "mail.registation_confirmation.subject", tournament: @registration.tournament.name))
  end

  def registration_cancelation(cancellation)
    @cancellation = cancellation
    mail(to: cancellation.fetch(:email), bcc: ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"), subject: (t "mail.registation_cancelation.subject", tournament: cancellation.fetch(:tournament_name)))
  end

  def registration_changed(registration)
    @registration = registration
    mail(to: @registration.email, bcc: ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"), subject: (t "mail.registation_change.subject", tournament: @registration.tournament.name))
  end
end
