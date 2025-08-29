class User < ApplicationRecord
  has_secure_password

  # Associations
  belongs_to :course, optional: true
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :questions, dependent: :destroy
  has_many :simulations, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :corrections, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Validations
  validates :name, :email, :password_digest, :role, presence: true
  validates :email, uniqueness: true
  
  # Scopes
  scope :by_course, ->(course_id) { where(course_id: course_id) if course_id.present? }
  scope :by_name, -> { order(:name) }
  scope :students, -> { where(role: 0) }
  scope :teachers, -> { where(role: 1) }
  scope :admins, -> { where(role: 2) }
  
  # Methods
  def course_name
    course&.name
  end
  
  def course_code
    course&.code
  end
end
