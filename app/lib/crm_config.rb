# Конфигурация CRM. Читается из ENV.
#
# Философия: никаких режимов "или-или". Каждый способ входа и каждый канал
# интеграции — самостоятельная механика, которая работает, если
# сконфигурирована, и молчит, если нет. Всё может быть включено одновременно.
module CrmConfig
  module_function

  # Парольный вход включён всегда, кроме явного запрета
  # (PASSWORD_AUTH=disabled — для инсталляций, где пароли запрещены политикой).
  def password_auth? = ENV["PASSWORD_AUTH"] != "disabled"

  # SSO включается сам, как только сконфигурирован (ключ + issuer).
  def sso_enabled? = Sso.configured?

  # Входящие API-токены: ENV INBOUND_API_TOKENS = "source1:token1,source2:token2".
  # Fail-closed: не сконфигурировано — значит, входящий канал закрыт.
  def inbound_sources
    ENV["INBOUND_API_TOKENS"].to_s.split(",").filter_map do |pair|
      source, token = pair.split(":", 2)
      [ source.to_s.strip, token.to_s.strip ] if source.to_s.strip.present? && token.to_s.strip.present?
    end.to_h
  end

  # Определяет источник по присланному токену (константное сравнение).
  # nil = токен никому не принадлежит.
  def source_for_token(provided)
    return nil if provided.blank?

    inbound_sources.find { |_source, token| ActiveSupport::SecurityUtils.secure_compare(token, provided) }&.first
  end

  # Внешний SSO. Провайдер любой, лишь бы подписывал JWT RS256.
  module Sso
    module_function

    def configured? = public_key_pem.present? && issuer.present?

    def provider_name = ENV.fetch("SSO_PROVIDER_NAME", "sso")
    def authorize_url = ENV["SSO_AUTHORIZE_URL"].presence
    def issuer = ENV["SSO_ISSUER"].presence
    def audience = ENV.fetch("SSO_AUDIENCE", "brickcrm")

    def public_key_pem
      raw = ENV["SSO_PUBLIC_KEY_BASE64"].to_s
      return "" if raw.blank?

      Base64.decode64(raw)
    end
  end
end
