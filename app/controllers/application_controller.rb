class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  # Гейт раздела: permission?(раздел, действие) по ролям пользователя
  def require_permission!(section, action)
    return if current_user&.permission?(section.to_s, action.to_s)

    redirect_to root_path, alert: "Недостаточно прав: #{Role.section_name(section)} — #{Role.action_name(action)}"
  end

  def forbidden
    redirect_back fallback_location: root_path, alert: "Недостаточно прав для этого действия"
  end
end
