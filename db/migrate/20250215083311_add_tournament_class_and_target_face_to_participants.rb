class AddTournamentClassAndTargetFaceToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_reference :participants, :tournament_class, foreign_key: true
    add_reference :participants, :target_face, foreign_key: true
  end
end
