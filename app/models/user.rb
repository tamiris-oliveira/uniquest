class User < ApplicationRecord
  has_secure_password

  # Associations
  belongs_to :course, optional: true
  belongs_to :approved_by_user, class_name: 'User', foreign_key: 'approved_by', optional: true
  has_many :approved_users, class_name: 'User', foreign_key: 'approved_by', dependent: :nullify
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :questions, dependent: :destroy
  has_many :simulations, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :corrections, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Enums
  enum :approval_status, {
    pending: 0,      # Aguardando aprovação
    approved: 1,     # Aprovado
    rejected: 2,     # Rejeitado
    suspended: 3     # Suspenso
  }

  # Validations
  validates :name, :email, :password_digest, :role, :approval_status, presence: true
  validates :email, uniqueness: true
  validates :role, inclusion: { in: [0, 1, 2, 3] } # 0: student, 1: teacher, 2: admin, 3: super_admin
  
  # Validações customizadas
  validate :teacher_requires_approval
  validate :admin_email_domain
  
  # Callbacks
  before_validation :set_default_approval_status, on: :create
  after_create :send_approval_notification, if: :teacher_pending_approval?
  
  # Scopes
  scope :by_course, ->(course_id) { where(course_id: course_id) if course_id.present? }
  scope :by_name, -> { order(:name) }
  scope :students, -> { where(role: 0) }
  scope :teachers, -> { where(role: 1) }
  scope :admins, -> { where(role: 2) }
  scope :super_admins, -> { where(role: 3) }
  scope :active, -> { where(approval_status: :approved) }
  scope :pending_approval, -> { where(approval_status: :pending) }
  
  # Methods
  def course_name
    course&.name
  end
  
  def course_code
    course&.code
  end
  
  def student?
    role == 0
  end
  
  def teacher?
    role == 1
  end
  
  def admin?
    role == 2
  end
  
  def super_admin?
    role == 3
  end
  
  def can_access_system?
    student? || (teacher? && approved?) || (admin? && approved?) || super_admin?
  end
  
  def can_approve_users?
    admin? || super_admin?
  end
  
  def can_approve_admins?
    super_admin?
  end
  
  def can_approve_user?(target_user)
    return false unless can_approve_users?
    
    # Super admins podem aprovar qualquer um
    return true if super_admin?
    
    # Admins só podem aprovar professores do mesmo curso
    if admin? && target_user.teacher?
      return course_id.present? && target_user.course_id == course_id
    end
    
    # Admins não podem aprovar outros admins
    return false if admin? && target_user.admin?
    
    false
  end
  
  def teacher_pending_approval?
    teacher? && pending?
  end
  
  def approve!(approved_by_user)
    update!(
      approval_status: :approved,
      approved_by: approved_by_user.id,
      approved_at: Time.current
    )
  end
  
  def reject!(rejected_by_user)
    update!(
      approval_status: :rejected,
      approved_by: rejected_by_user.id,
      approved_at: Time.current
    )
  end
  
  private
  
  def set_default_approval_status
    if student?
      self.approval_status = :approved  # Alunos são aprovados automaticamente
    elsif teacher?
      self.approval_status = :pending   # Professores precisam de aprovação
    elsif admin?
      self.approval_status = :pending   # Admins precisam de aprovação de Super Admin
    elsif super_admin?
      self.approval_status = :approved  # Super Admins são aprovados automaticamente
    end
  end
  
  def teacher_requires_approval
    if teacher? && approval_status == 'approved' && approved_by.blank?
      errors.add(:approval_status, 'Professores devem ser aprovados por um administrador')
    end
  end
  
  def admin_email_domain
    if admin? && !email.ends_with?('@admin.uniquest.com')
      errors.add(:email, 'Administradores devem usar email @admin.uniquest.com')
    end
  end
  
  def send_approval_notification
    if teacher?
      # Notificar admins do mesmo curso e super admins sobre novo professor pendente
      admins_to_notify = []
      
      # Super admins sempre são notificados
      admins_to_notify += User.super_admins.approved.to_a
      
      # Admins do mesmo curso (se o professor tiver curso)
      if course_id.present?
        admins_to_notify += User.admins.approved.where(course_id: course_id).to_a
      else
        # Se não tiver curso, notificar todos os admins
        admins_to_notify += User.admins.approved.to_a
      end
      
      admins_to_notify.uniq.each do |admin|
        Notification.create!(
          user: admin,
          message: "Novo professor aguardando aprovação: #{name} (#{email})#{course&.name ? " - Curso: #{course.name}" : ""}",
          viewed: false,
          send_date: Time.current
        )
      end
    elsif admin?
      # Notificar apenas super admins sobre novo admin pendente
      User.super_admins.approved.find_each do |super_admin|
        Notification.create!(
          user: super_admin,
          message: "Novo administrador aguardando aprovação: #{name} (#{email})#{course&.name ? " - Curso: #{course.name}" : ""}",
          viewed: false,
          send_date: Time.current
        )
      end
    end
  end
end
