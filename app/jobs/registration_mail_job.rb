class RegistrationMailJob < ApplicationJob
  def perform(registration, action)
    removed = registration.with_lock do
      registration.remove_duplicate_participants!
    end
    return unless action

    ParticipantMailer.public_send(action, registration, removed).deliver_later
  end
end
