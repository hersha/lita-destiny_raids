require "spec_helper"

describe Lita::Handlers::DestinyRaids, lita_handler: true do
  it { is_expected.to route("raid new kings fall").to :new }
  describe "#new" do
    it "creates a new raid" do
      send_message "raid new wtf"
      id = replies.last[-6..-1]
      key = "destiny:raid:#{id}"
      expect(Lita.redis.get("destiny:raid:#{id}")).to eq Raid.new(name:"wtf").to_json
    end
  end

  it { is_expected.to route("raid list").to :list }
  describe "#list" do
    it "lists all raids" do
      send_message "raid new wtf"
      send_message "raid new wtf"
      send_message "raid list"
      expect(replies.last.lines.size).to eq 3
    end
  end

  it { is_expected.to route("raid show fe1236a").to :show }
  describe "#show" do
    it "displays a raid" do
      send_message "raid new wtf"
      id = replies.last[-6..-1]
      send_message "raid signup #{id}"
      send_message "raid show #{id}"
      expect(replies.last.lines.size).to eq 8
    end
  end

  it { is_expected.to route("raid signup 123456").to :signup }
  describe "#signup" do
    it "adds people to the raid" do
      send_message "raid new wtf"
      id = replies.last[-6..-1]
      send_message "raid signup #{id}"
      raid = Raid.from_json(Lita.redis.get("destiny:raid:#{id}"))
      expect(raid.members.size).to eq 1
    end
  end
end
