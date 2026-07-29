class User < ApplicationRecord
  has_secure_password validations: false

  has_many :sessions, dependent: :destroy
  has_many :memberships, -> { where(active: true) }, inverse_of: :user, dependent: :destroy
  has_many :roles, through: :memberships
  has_many :branches, through: :memberships

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_required_for_local_accounts

  scope :active, -> { where(active: true) }

  # Аккаунт из внешнего провайдера идентичности — без локального пароля
  def sso? = provider.present?

  # Гейт входа: активен И есть хотя бы один активный membership.
  # Роль во внешней системе значения не имеет.
  def can_sign_in? = active? && memberships.exists?

  def permission?(section, action)
    roles.any? { |role| role.allows?(section, action) }
  end

  # Есть membership без филиала => доступ ко всей сети
  def global_access? = memberships.any? { |m| m.branch_id.nil? }

  def branch_ids_in_scope = memberships.filter_map(&:branch_id)

  private

  def password_required_for_local_accounts
    return if sso?

    errors.add(:password, :blank) if password_digest.blank?
  end
end
