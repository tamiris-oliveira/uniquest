class Course < ApplicationRecord
  # Associations
  has_many :users, dependent: :restrict_with_error
  has_many :groups, -> { distinct }, through: :users
  has_many :simulations, -> { distinct }, through: :groups
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :code, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 2, maximum: 20 }
  validates :description, length: { maximum: 500 }
  
  # Scopes
  scope :active, -> { joins(:users).distinct }
  scope :by_name, -> { order(:name) }
  
  # Methods
  def to_s
    "#{code} - #{name}"
  end
  
  def users_count
    users.count
  end
  
  def groups_count
    groups.count
  end
end
