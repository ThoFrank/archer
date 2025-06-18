class ParticipantValidator < ActiveModel::Validator
  def validate(record)
    base_date = record.Tournament.date_start
    tournament_class = record.tournament_class
    age_end = tournament_class.andand.age_end || 100
    age_start = tournament_class.andand.age_start || 0
    date_start = base_date - age_end.years
    date_end = base_date - age_start.years + 1.year - 1.day

    unless record.dob && date_start <= record.dob && record.dob <= date_end
      record.errors.add :tournament_class
    end

    unless record.tournament_class && record.tournament_class.target_faces.include?(record.target_face)
      record.errors.add :target_face
    end

    unless URI::MailTo::EMAIL_REGEXP.match?(record.email)
      record.errors.add :email
    end

  end
end

class Participant < ApplicationRecord
  belongs_to :Tournament
  belongs_to :tournament_class
  belongs_to :target_face

  validates :Tournament, presence: true
  validates :tournament_class, presence: true
  validates :target_face, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dob, presence: true
  validates_with ParticipantValidator
end
