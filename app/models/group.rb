class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  validates :name, :invite_code, presence: true
  validates :invite_code, uniqueness: true
end
