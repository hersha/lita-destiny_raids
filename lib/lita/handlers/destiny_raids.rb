module Lita
  module Handlers
    class DestinyRaids < Handler
      route(/^raid new (.*)$/, :new)

      def new(response)
        response.reply(response.matches.to_s)
      end

      Lita.register_handler(self)
    end
  end
end
