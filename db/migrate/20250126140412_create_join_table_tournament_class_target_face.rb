class CreateJoinTableTournamentClassTargetFace < ActiveRecord::Migration[8.0]
  def change
    create_join_table :tournament_classes, :target_faces
  end
end
