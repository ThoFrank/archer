class Group < ApplicationRecord
  belongs_to :tournament
  has_many :participants, dependent: :nullify

  enum :status, active: "active", closed: "closed"
end
