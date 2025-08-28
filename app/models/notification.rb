class Notification < ApplicationRecord
  belongs_to :user

  validates :message, presence: true
  validates :viewed, inclusion: { in: [ true, false ] }
  validates :send_date, presence: true
end
