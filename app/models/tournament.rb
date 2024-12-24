class Tournament < ApplicationRecord
  has_many :participants
  validates :name, presence: true
  validate :valid_dates

  def valid_dates
    def valid_date(date)
    puts date
      if date.blank?
        return "can't be blank"
      elsif !date.is_a?(ActiveSupport::TimeWithZone)
        return "must be a valid date"
      end
    end

    def valid_date_string?(date_string)
      Date.parse(date_string) rescue false
    end

    e = valid_date(date_start)
    if e
      errors.add(:date_start, e)
    end
    e = valid_date(date_end)
    if e
      errors.add(:date_end, e)
    end
    if date_start && date_end && date_end.utc() < date_start.utc()
      errors.add(:date_end, "must not be earlier than begin")
    end
  end

end
