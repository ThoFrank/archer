class RegistrationParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :registration_participants do |t|
      t.references :registration, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
    end

    Participant.all.each do |p|
      registration = Registration.new()
      registration.email = p.email
      registration.tournament = p.Tournament
      registration.save!
      p.registration = registration
      p.save!
    end

    remove_column :participants, :email, :string
  end
end
