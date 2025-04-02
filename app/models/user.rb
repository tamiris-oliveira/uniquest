class User < ApplicationRecord
  has_secure_password

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  validates :name, :email, :password_digest, :role, presence: true
  validates :email, uniqueness: true
end
