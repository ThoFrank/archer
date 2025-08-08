class RegistrationParticipant < ApplicationRecord
  belongs_to :registration
  belongs_to :participant
end
