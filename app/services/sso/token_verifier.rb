module Sso
  # Валидация подписанного JWT от внешнего провайдера идентичности.
  # Проверяются: подпись RS256, exp, iat, iss, aud. Fail-closed:
  # отсутствие ключа или issuer в конфигурации = отказ, а не пропуск.
  class TokenVerifier
    InvalidToken = Class.new(StandardError)

    ALGORITHM = "RS256"
    EXP_LEEWAY = 30 # секунд рассинхрона часов

    Identity = Struct.new(:external_uid, :email, :name, keyword_init: true)

    def verify!(token)
      payload, _header = JWT.decode(
        token,
        public_key,
        true,
        algorithm: ALGORITHM,
        verify_expiration: true,
        verify_iat: true,
        iss: issuer, verify_iss: true,
        aud: CrmConfig::Sso.audience, verify_aud: true,
        exp_leeway: EXP_LEEWAY
      )

      Identity.new(
        external_uid: payload.fetch("sub").to_s,
        email: payload.fetch("email"),
        name: payload["name"].to_s
      )
    rescue JWT::DecodeError => e
      raise InvalidToken, e.message
    rescue KeyError
      raise InvalidToken, "в токене нет обязательных полей (sub, email)"
    end

    private

    def issuer
      CrmConfig::Sso.issuer or raise InvalidToken, "SSO_ISSUER не сконфигурирован"
    end

    def public_key
      pem = CrmConfig::Sso.public_key_pem
      raise InvalidToken, "SSO_PUBLIC_KEY_BASE64 не сконфигурирован" if pem.blank?

      OpenSSL::PKey::RSA.new(pem)
    rescue OpenSSL::PKey::RSAError => e
      raise InvalidToken, "некорректный публичный ключ: #{e.message}"
    end
  end
end
