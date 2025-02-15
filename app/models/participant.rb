class Participant < ApplicationRecord
  belongs_to :Tournament
  belongs_to :tournament_class
  belongs_to :target_face
end
