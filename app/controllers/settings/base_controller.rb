module Settings
  # Раздел настроек: просмотр — право settings/read, изменение — settings/manage.
  class BaseController < ApplicationController
    before_action :require_settings_read

    private

    def require_settings_read
      return if current_user.permission?("settings", "read") || current_user.permission?("settings", "manage")

      redirect_to root_path, alert: "Недостаточно прав для раздела настроек"
    end

    def require_settings_manage
      return if current_user.permission?("settings", "manage")

      redirect_to settings_root_path, alert: "Изменять настройки может только роль с правом «управление»"
    end
  end
end
