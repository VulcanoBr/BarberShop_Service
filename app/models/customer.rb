class Customer < ApplicationRecord

  has_secure_password

  has_many :appointments

  # Validações
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:password_digest] }

  # Callbacks
  before_save :downcase_email
  before_create :generate_confirmation_token

  # Métodos para autenticação
  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update_columns(confirmed_at: Time.current, confirmation_token: nil)
  end

  def generate_password_reset_token!
    update_columns(
      reset_password_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.current
    )
  end

  def password_reset_expired?
    reset_password_sent_at < 2.hours.ago
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

end
