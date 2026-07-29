module Sso
  # Заводит/обновляет пользователя CRM по внешней идентичности.
  # Первичный ключ связи — (provider, external_uid), вторичный — нормализованный
  # email (усыновляем локальный аккаунт с тем же email, чтобы не плодить дубли).
  class IdentityUpserter
    def initialize(identity)
      @identity = identity
    end

    def call
      provider = CrmConfig::Sso.provider_name

      user = User.find_by(provider: provider, external_uid: @identity.external_uid)
      user ||= adopt_local_user(provider)
      user ||= User.new(provider: provider, external_uid: @identity.external_uid)

      user.email = @identity.email
      user.name = @identity.name if @identity.name.present?
      user.save!
      user
    end

    private

    def adopt_local_user(provider)
      User.find_by(email: @identity.email.strip.downcase)&.tap do |user|
        user.provider = provider
        user.external_uid = @identity.external_uid
      end
    end
  end
end
