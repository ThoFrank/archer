class ParticipantValidator < ActiveModel::Validator
  def validate(record)
    tournament_class = record.tournament_class
    if tournament_class
      date_start = tournament_class.from_date
      date_end = tournament_class.to_date
    else
      date_start = Date.new(1900)
      date_end = Date.today
    end

    unless record.dob && date_start <= record.dob && record.dob <= date_end
      record.errors.add :tournament_class
    end

    unless record.tournament_class && record.tournament_class.target_faces.include?(record.target_face)
      record.errors.add :target_face
    end

    unless record.registration && URI::MailTo::EMAIL_REGEXP.match?(record.registration.email)
      record.errors.add :registration
    end
  end
end

class Participant < ApplicationRecord
  belongs_to :Tournament
  belongs_to :tournament_class
  belongs_to :target_face
  belongs_to :group, optional: true

  has_one :registration_participant
  has_one :registration, through: :registration_participant

  validates :Tournament, presence: true
  validates :tournament_class, presence: true
  validates :target_face, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :club, presence: true, if: Proc.new { |record| record.Tournament.enforce_club }
  validates :group, presence: true, if: Proc.new { |record| record.Tournament.groups.any? }
  validates :dob, presence: true
  validates_with ParticipantValidator
end
