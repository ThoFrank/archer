class ParticipantMailer < ApplicationMailer
  def registration_confirmation(registration, removed_participants = [])
    @registration = registration
    @removed_participants = removed_participants
    headers["Message-ID"] = registration_thread_id(@registration.id)
    mail(to: @registration.email, bcc: sender_address, subject: registration_subject(@registration.tournament.name))
  end

  def registration_cancelation(cancellation)
    @cancellation = cancellation
    set_registration_thread_headers(cancellation[:registration_id]) if cancellation[:registration_id]
    mail(to: cancellation.fetch(:email), bcc: sender_address, subject: registration_subject(cancellation.fetch(:tournament_name)))
  end

  def registration_changed(registration, removed_participants = [])
    @registration = registration
    @removed_participants = removed_participants
    set_registration_thread_headers(@registration.id)
    mail(to: @registration.email, bcc: sender_address, subject: registration_subject(@registration.tournament.name))
  end

  private
    def set_registration_thread_headers(registration_id)
      thread_id = registration_thread_id(registration_id)
      headers["In-Reply-To"] = thread_id
      headers["References"] = thread_id
    end

    def registration_thread_id(registration_id)
      "<archer-registration-#{registration_id}@#{Mail::Address.new(sender_address).domain}>"
    end

    def registration_subject(tournament_name)
      t "mail.registation_confirmation.subject", tournament: tournament_name
    end

    def sender_address
      ENV.fetch("ARCHER_DEFAULT_MAIL_ADDRESS", "from@example.com")
    end
end
