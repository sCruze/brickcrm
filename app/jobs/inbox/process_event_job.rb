module Inbox
  class ProcessEventJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 5

    def perform(inbox_event_id)
      event = InboxEvent.find(inbox_event_id)
      return if event.status == "processed"

      Inbox::Router.new(event).call
      event.update!(status: "processed", processed_at: Time.current, last_error: nil)
    rescue StandardError => e
      event&.update_columns(status: "failed", last_error: e.message.truncate(1000),
                            attempts: event.attempts + 1, updated_at: Time.current)
      raise
    end
  end
end
