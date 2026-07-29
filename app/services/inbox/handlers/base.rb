module Inbox
  module Handlers
    class Base
      attr_reader :event, :payload

      def initialize(event)
        @event = event
        @payload = event.payload
      end
    end
  end
end
