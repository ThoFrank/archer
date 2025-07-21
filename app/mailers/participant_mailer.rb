class ParticipantMailer < ApplicationMailer
  def registration_confirmation(participant)
    @participant = participant
    mail(to: participant.email, bcc: ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"), subject: (t "mail.registation_confirmation.subject", tournament: @participant.Tournament.name))
  end

  def registration_cancelation(participant)
    @participant = participant
    mail(to: participant.email, bcc: ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com"), subject: (t "mail.registation_cancelation.subject", tournament: @participant.Tournament.name))
  end
end
