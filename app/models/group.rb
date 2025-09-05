class Group < ApplicationRecord
  belongs_to :tournament
  has_many :participants, dependent: :nullify
end
