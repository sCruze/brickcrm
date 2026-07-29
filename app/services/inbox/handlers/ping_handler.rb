module Inbox
  module Handlers
    # Тестовый обработчик для проверки контура доставки end-to-end.
    class PingHandler < Base
      def call
        Rails.logger.info("[inbox] ping от #{event.source}: #{payload.inspect}")
      end
    end
  end
end
