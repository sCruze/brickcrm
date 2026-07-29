class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def forbidden
    redirect_back fallback_location: root_path, alert: "Недостаточно прав для этого действия"
  end
end
