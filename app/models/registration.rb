class Registration < ApplicationRecord
  belongs_to :tournament

  has_many :registration_participants, dependent: :delete_all
  has_many :participants, through: :registration_participants
end
