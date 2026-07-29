module Outbox
  # Доставка исходящих событий во внешние системы. Запускается по расписанию
  # (config/recurring.yml). Адресат — WebhookEndpoint с name = event.destination.
  # Идемпотентность на приёмнике — по заголовку Idempotency-Key.
  class DrainerJob < ApplicationJob
    queue_as :default

    BATCH = 100

    def perform
      OutboxEvent.pending.order(:id).limit(BATCH).each { |event| deliver(event) }
    end

    private

    def deliver(event)
      endpoint = WebhookEndpoint.active.find_by(name: event.destination)
      return event.register_failure!("Нет активного webhook-эндпоинта '#{event.destination}'") if endpoint.nil?

      response = client(endpoint).post do |req|
        req.headers["Authorization"] = "Bearer #{endpoint.token}" if endpoint.token.present?
        req.headers["Idempotency-Key"] = "brickcrm-outbox-#{event.id}"
        req.body = {
          entity_type: event.entity_type,
          entity_id: event.entity_id,
          event: event.event,
          payload: event.payload
        }
      end

      if response.success?
        event.update!(status: "delivered", delivered_at: Time.current, last_error: nil)
      else
        event.register_failure!("HTTP #{response.status}")
      end
    rescue Faraday::Error => e
      event.register_failure!(e.message)
    end

    def client(endpoint)
      Faraday.new(url: endpoint.url) do |f|
        f.request :json
        f.response :json
        f.options.timeout = 10
        f.options.open_timeout = 3
      end
    end
  end
end
