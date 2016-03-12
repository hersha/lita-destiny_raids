module Lita
  module Handlers
    class DestinyRaids < Handler
      route(/^raid new (.*)$/, :new)

      def new(response)
        name = response.user.metadata['mention_name'].nil? ?
                 "#{response.user.name}" : 
                 "#{response.user.metadata['mention_name']}"
        response.reply(name)
      end

      Lita.register_handler(self)
    end
  end
end
