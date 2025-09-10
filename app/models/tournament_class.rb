class TournamentClass < ApplicationRecord
  belongs_to :tournament
  has_many :target_faces_tournament_classes, dependent: :destroy
  has_many :target_faces, through: :target_faces_tournament_classes
  # has_many :target_faces, join_table: :target_faces_tournament_classes
  has_many :participants, dependent: :nullify


  # Date used for age calculation
  def base_date
    self.tournament.andand.season_start_date || self.tournament.andand.date_start.andand.to_date || Date.today
  end

  # Latest birthday date allowed for the class
  def to_date
    base_date - self.age_start.years + 1.year - 1.day
  end

  # Earliest birthday date allowed for the class
  def from_date
    base_date - self.age_end.years
  end
end
