class Registration < ApplicationRecord
  belongs_to :tournament

  has_many :registration_participants, dependent: :delete_all
  has_many :participants, through: :registration_participants

  def remove_duplicate_participants!
    return [] unless tournament.prevent_duplicate_registrations?

    transaction do
      participants.order(:id).filter_map do |participant|
        duplicate = tournament.participants.where(
          first_name: participant.first_name, last_name: participant.last_name, dob: participant.dob
        ).where("participants.id < ?", participant.id).exists?
        next unless duplicate

        removed = { first_name: participant.first_name, last_name: participant.last_name, dob: participant.dob }
        # Unlink first: Participant#destroy would otherwise destroy the whole registration.
        participant.registration_participant.destroy!
        participant.reload.destroy!
        removed
      end
    end
  end

  # Keep the older registration so already queued emails still refer to it.
  # Call before queuing any mail for this registration.
  def combine_with_existing!
    transaction do
      clubs = participants.distinct.pluck(:club)
      next self unless clubs.length == 1

      existing = Registration.where(tournament_id: tournament_id, email: email)
        .where("id < ?", id).order(:id).detect do |registration|
          registration.participants.distinct.pluck(:club) == clubs
        end
      next self unless existing

      existing.update!(comment: [ existing.comment, comment ].reject(&:blank?).join("\n"))
      registration_participants.update_all(registration_id: existing.id)
      destroy!
      existing
    end
  end
end
