class TargetFace < ApplicationRecord
  belongs_to :tournament
  has_many :target_faces_tournament_classes, dependent: :delete_all
  has_many :tournament_classes, through: :target_faces_tournament_classes
  has_many :participants, dependent: :nullify
end
