class ParticipantMailer < ApplicationMailer
  def registration_confirmation(participant)
    @participant = participant
    mail(to: participant.email, subject: (t "mail.registation_confirmation.subject", tournament: @participant.Tournament.name))
  end
end
