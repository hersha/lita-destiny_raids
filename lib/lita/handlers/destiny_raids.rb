require "securerandom"
module Lita
  module Handlers
    class DestinyRaids < Handler
      route(/^raid new (.*)$/, :new)
      route(/^raid list$/, :list)
      route(/^raid show (.*)$/, :show)
      route(/^raid signup (.*)$/, :signup)

      def new(response)
        name = response.matches.first.first
        raid = Raid.new name: name
        id = SecureRandom.hex(6)[0..5]
        Lita.redis.set "destiny:raid:#{id}", raid.to_json
        response.reply("Created new raid id: #{id}")
      end

      def list(response)
        keys = Lita.redis.keys "destiny:raid:*"
        header = "Found #{keys.size} raids:\n"
        body = keys.map do |k|
          id = k.split(":").last
          raid = Raid.from_json Lita.redis.get(k)
          "\t#{id} | #{raid.status}"
        end.join("\n")
        response.reply(header + body)
      end

      def show(response)
        id = response.matches.first.first
        key = "destiny:raid:#{id}"
        raid = Raid.from_json Lita.redis.get key
        header = "ID: #{id} - Raid: #{raid.name}\nMembers:\n"
        members = "1: #{raid.leader || "Empty"} (Leader)\n" 
        (2..6).each do |i|
          members += "#{i}: #{raid.members[i-2] || "Empty"}\n"
        end
        standbys = ""
        if raid.stand_bys.count > 0
          standbys += "\nStandbys:\n"
          raid.stand_bys.each.with_index do |s, i|
            standbys += "#{i+1}: #{s}"
          end
        end
        response.reply(header + members + standbys)
      end

      def signup(response)
        key = "destiny:raid:#{response.matches.first.first}"
        raid = Raid.from_json Lita.redis.get key
        raid.sign_up(username(response))
        Lita.redis.set key, raid.to_json
        response.reply("Signed up for #{raid.name}")
      end

    private
      def username(response)
        response.user.metadata['mention_name'].nil? ?
                 "#{response.user.name}" : 
                 "#{response.user.metadata['mention_name']}"
      end


      Lita.register_handler(self)
    end
  end
end
