class Question < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :subject
  has_many :alternatives, dependent: :destroy
  has_many :question_simulations, dependent: :destroy
  has_many :simulations, through: :question_simulations
  has_many :answers, dependent: :destroy

  # Validations
  validates :statement, :question_type, presence: true
  validates :question_type, inclusion: { in: [ "Objetiva", "Discursiva" ] }
  
  # Nested attributes
  accepts_nested_attributes_for :alternatives, allow_destroy: true
  
  # Scopes
  scope :by_course, ->(course_id) { 
    joins(:user).where(users: { course_id: course_id }) if course_id.present?
  }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) if subject_id.present? }
  scope :by_type, ->(question_type) { where(question_type: question_type) if question_type.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :search_statement, ->(term) { where('statement ILIKE ?', "%#{term}%") if term.present? }
  scope :recent, -> { order(created_at: :desc) }
  
  # Methods
  def course
    user&.course
  end
  
  def course_name
    course&.name
  end
  
  def author_name
    user&.name
  end
end
