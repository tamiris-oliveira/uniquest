class Group < ApplicationRecord
  # Associations
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  has_many :group_simulations, dependent: :destroy
  has_many :simulations, through: :group_simulations
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', optional: true

  # Validations
  validates :name, :invite_code, presence: true
  validates :invite_code, uniqueness: true
  
  # Scopes
  scope :by_course, ->(course_id) { 
    joins(:users).where(users: { course_id: course_id }).distinct if course_id.present?
  }
  scope :by_name, -> { order(:name) }
  scope :with_users_from_course, ->(course_id) {
    joins(:users).where(users: { course_id: course_id }).distinct
  }
  
  # Methods
  def users_count
    users.count
  end
  
  def simulations_count
    simulations.count
  end
  
  def course_names
    users.joins(:course).pluck('courses.name').uniq.compact
  end
end
