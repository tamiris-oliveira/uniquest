class User < ApplicationRecord
  has_secure_password

  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy

  validates :name, :email, :password_digest, :role, presence: true
  validates :email, uniqueness: true
end
