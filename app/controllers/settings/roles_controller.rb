module Settings
  class RolesController < BaseController
    before_action :require_settings_manage, except: :index
    before_action :set_role, only: %i[edit update destroy]

    def index
      @roles = Role.order(:id)
    end

    def new
      @role = Role.new
    end

    def create
      @role = Role.new(role_params)
      @role.permissions = permitted_permissions

      if @role.save
        redirect_to settings_roles_path, notice: "Роль «#{@role.name}» создана"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      attrs = role_params
      attrs = attrs.except(:key) if @role.system?     # ключ системной роли неизменен
      @role.assign_attributes(attrs)
      @role.permissions = permitted_permissions unless @role.system?

      if @role.save
        redirect_to settings_roles_path, notice: "Роль «#{@role.name}» обновлена"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @role.system?
        redirect_to settings_roles_path, alert: "Системную роль удалить нельзя"
      elsif @role.destroy
        redirect_to settings_roles_path, notice: "Роль удалена"
      else
        redirect_to settings_roles_path, alert: @role.errors.full_messages.join(", ")
      end
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:key, :name)
    end

    # Матрица чекбоксов -> строго известные разделы и действия
    def permitted_permissions
      raw = params[:role][:permissions]
      raw = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : (raw || {})

      Role::SECTIONS.each_with_object({}) do |section, acc|
        actions = Array(raw[section]).map(&:to_s) & Role::ACTIONS
        acc[section] = actions if actions.any?
      end
    end
  end
end
