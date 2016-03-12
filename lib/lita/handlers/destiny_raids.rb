require "securerandom"
module Lita
  module Handlers
    class DestinyRaids < Handler
      config :channel_white_list, type: Array, default: []

      route(/^raid new (.*)$/, :new, help: {
        "raid new <RAID NAME>" => "Creates new raid with supplied name"
      })
      route(/^raid list$/, :list, help: {
        "raid list" => "Lists all existing raids"
      })
      route(/^raid show (.{6})$/, :show, help: {
        "raid show <ID>" => "Displays raid information"
      })
      route(/^raid signup (.{6})$/, :signup, help: {
        "raid signup <ID>" => "Signup for a raid"
      })
      route(/^raid assign_leader (.{6}) (.*)$/, :assign_leader, help: {
        "raid assign_leader <ID> <NAME>" => "Assign person to a raid leader position"
      })
      route(/^raid leave (.{6})$/, :leave, help: {
        "raid leave <ID>" => "Leave a raid"
      })
      route(/^raid delete (.{6}$)/, :delete, help: {
        "raid delete <ID>" => "Delete a raid"
      })
      route(/^raid debug$/, :debug)

      def new(response)
        return unless can_i_respond?(response)
        name = response.matches.first.first
        raid = Raid.new name: name
        id = SecureRandom.hex(6)[0..5]
        Lita.redis.set "destiny:raid:#{id}", raid.to_json
        response.reply("Created new raid id: #{id}")
      end

      def list(response)
        return unless can_i_respond?(response)
        keys = Lita.redis.keys "destiny:raid:*"
        return response.reply("No raids found") if keys.empty?
        header = "Found #{keys.size} raids:\n"
        body = keys.map do |k|
          id = k.split(":").last
          raid = Raid.from_json Lita.redis.get(k)
          "\t#{id} | #{raid.status}"
        end.join("\n")
        response.reply(header + body)
      end

      def show(response)
        return unless can_i_respond?(response)
        id = response.matches.first.first
        key = get_key(response)
        return response.reply("Raid #{id} does not exist") unless raid_exist?(key)
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
        return unless can_i_respond?(response)
        key = get_key(response)
        return response.reply("Raid #{id} does not exist") unless raid_exist?(key)
        raid = Raid.from_json Lita.redis.get key
        raid.sign_up(username(response))
        Lita.redis.set key, raid.to_json
        response.reply("Signed up for #{raid.name}")
      end

      def assign_leader(response)
        return unless can_i_respond?(response)
        key = get_key(response)
        return response.reply("Raid #{id} does not exist") unless raid_exist?(key)
        leader = response.matches.first.last
        raid = Raid.from_json Lita.redis.get key
        raid.leader = leader
        Lita.redis.set key, raid.to_json
        response.reply("#{leader} is now the leader of \"#{raid.name}\"")
      end

      def leave(response)
        return unless can_i_respond?(response)
        key = get_key(response)
        return response.reply("Raid #{id} does not exist") unless raid_exist?(key)
        raid = Raid.from_json Lita.redis.get key
        raid.leave(username(response))
        Lita.redis.set key, raid.to_json
        response.reply("Left #{raid.name}")
      end

      def delete(response)
        return unless can_i_respond?(response)
        key = get_key(response)
        return response.reply("Raid #{id} does not exist") unless raid_exist?(key)
        raid = Raid.from_json Lita.redis.get key
        Lita.redis.del key
        response.reply("Deleted \"raid.name\"")
      end
       
      def debug(response)
        source = response.message.source
        response.reply(source.room)
      end

    private
      def username(response)
        response.user.metadata['mention_name'].nil? ?
                 "#{response.user.name}" : 
                 "#{response.user.metadata['mention_name']}"
      end

      def get_key(response)
        "destiny:raid:#{response.matches.first.first}"
      end


      def raid_exist?(key)
        Lita.redis.exists key
      end

      def can_i_respond?(response)
        return true if response.message.source.private_message
        return true if config.channel_white_list.empty?
        return true if config.channel_white_list.include? response.message.source.room
        false
      end


      Lita.register_handler(self)
    end
  end
end
