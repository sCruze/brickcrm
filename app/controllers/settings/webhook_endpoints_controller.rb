module Settings
  class WebhookEndpointsController < BaseController
    before_action :require_settings_manage, except: :index
    before_action :set_endpoint, only: %i[edit update destroy]

    def index
      @endpoints = WebhookEndpoint.order(:id)
    end

    def new
      @endpoint = WebhookEndpoint.new(active: true)
    end

    def create
      @endpoint = WebhookEndpoint.new(endpoint_params)

      if @endpoint.save
        redirect_to settings_webhook_endpoints_path, notice: "Эндпоинт «#{@endpoint.name}» создан"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @endpoint.update(endpoint_params)
        redirect_to settings_webhook_endpoints_path, notice: "Эндпоинт «#{@endpoint.name}» обновлён"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @endpoint.destroy
      redirect_to settings_webhook_endpoints_path, notice: "Эндпоинт удалён"
    end

    private

    def set_endpoint
      @endpoint = WebhookEndpoint.find(params[:id])
    end

    def endpoint_params
      params.require(:webhook_endpoint).permit(:name, :url, :token, :active)
    end
  end
end
