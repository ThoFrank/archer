class CreateJoinTableTournamentClassTargetFace < ActiveRecord::Migration[8.0]
  def change
    create_table :target_faces_tournament_classes do |t|
      t.references :tournament_class, index: true, foreign_key: true
      t.references :target_face, index: true, foreign_key: true
    end
  end
end
