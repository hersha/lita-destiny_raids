module Lita
  module Handlers
    class DestinyRaids < Handler
      route(/^raid new (.*)$/, :new)

      def new(response)
        name = response.matches.inspect
        response.reply(name)
      end

      Lita.register_handler(self)
    end
  end
end
