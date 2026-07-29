module Api
  class BaseController < ActionController::API
    private

    attr_reader :inbound_source

    # Fail-closed: токены не сконфигурированы ИЛИ присланный никому
    # не принадлежит => 401. Пустой токен никогда не означает "пропустить".
    def authenticate_inbound!
      provided = request.headers["Authorization"].to_s.delete_prefix("Bearer ").presence
      @inbound_source = CrmConfig.source_for_token(provided)

      render json: { error: "unauthorized" }, status: :unauthorized if @inbound_source.blank?
    end
  end
end
