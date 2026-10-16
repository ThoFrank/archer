class Session < ApplicationRecord
  TIMEOUT = 7.days

  belongs_to :user

  scope :active, -> { where("created_at > ?", TIMEOUT.ago) }

  def expires_at
    created_at + TIMEOUT
  end
end
