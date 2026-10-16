class Registration < ApplicationRecord
  belongs_to :tournament

  has_many :registration_participants, dependent: :delete_all
  has_many :participants, through: :registration_participants

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
