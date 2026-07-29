module Sso
  # Вход через внешний провайдер идентичности. Активен, когда SSO сконфигурирован.
  # Провайдер после аутентификации редиректит на /sso/callback?token=<подписанный JWT>.
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[start callback]

    before_action :ensure_enabled

    def start
      url = CrmConfig::Sso.authorize_url
      return redirect_to new_session_path, alert: "SSO_AUTHORIZE_URL не сконфигурирован" if url.blank?

      redirect_to url, allow_other_host: true
    end

    def callback
      identity = Sso::TokenVerifier.new.verify!(params.require(:token))
      user = Sso::IdentityUpserter.new(identity).call

      if user.can_sign_in?
        start_new_session_for(user)
        redirect_to after_authentication_url
      else
        redirect_to new_session_path,
                    alert: "Личность подтверждена, но доступ в CRM не выдан. Обратитесь к администратору."
      end
    rescue Sso::TokenVerifier::InvalidToken => e
      redirect_to new_session_path, alert: "Не удалось войти через SSO: #{e.message}"
    end

    private

    def ensure_enabled
      raise ActionController::RoutingError, "SSO не сконфигурировано" unless CrmConfig.sso_enabled?
    end
  end
end
