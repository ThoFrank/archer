class TournamentClass < ApplicationRecord
  belongs_to :tournament
  has_many :target_faces_tournament_classes
  has_many :target_faces, through: :target_faces_tournament_classes

  def to_dob()
    self.tournament.date_start.year - self.age_start
  end
  def from_dob()
    self.tournament.date_start.year - self.age_end
  end
end
