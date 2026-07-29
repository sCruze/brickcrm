module Api
  module V1
    # Входящий канал событий (inbox). Источник определяется по токену
    # (INBOUND_API_TOKENS). Идемпотентен: дедупликация по UNIQUE
    # (source, event_key) — ровно как индекс в БД, статус в дедупликации
    # не участвует. Дубликат получает 200 и no-op.
    class EventsController < BaseController
      before_action :authenticate_inbound!

      # POST /api/v1/events
      # { "event_key": "evt-123", "entity_type": "ping",
      #   "entity_id": "1", "event": "created", "payload": { ... } }
      def create
        event = InboxEvent.create_or_find_by!(source: inbound_source, event_key: event_params[:event_key]) do |e|
          e.entity_type = event_params[:entity_type]
          e.entity_id   = event_params[:entity_id]
          e.event       = event_params[:event]
          e.payload     = event_params[:payload] || {}
        end

        fresh = event.previously_new_record?
        Inbox::ProcessEventJob.perform_later(event.id) if fresh

        render json: { status: "accepted", duplicate: !fresh }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end

      private

      def event_params
        params.permit(:event_key, :entity_type, :entity_id, :event, payload: {})
      end
    end
  end
end
