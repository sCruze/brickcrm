module Inbox
  # Маршрутизация входящих событий по entity_type.
  # Точка расширения: на каждый тип сущности — свой Inbox::Handlers::<Type>Handler.
  class Router
    def initialize(event)
      @event = event
    end

    def call
      handler_class = "Inbox::Handlers::#{@event.entity_type.camelize}Handler".safe_constantize
      raise "Нет обработчика для entity_type=#{@event.entity_type}" unless handler_class

      handler_class.new(@event).call
    end
  end
end
