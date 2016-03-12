require "spec_helper"

describe Raid do
  it "has a name" do
    name = double
    raid = Raid.new name: name
    expect(raid.name).to eq name
  end
  it "has a leader" do
    leader = double
    raid = Raid.new leader: leader
    expect(raid.leader).to eq leader
  end
  it "has members" do
    members = [double, double]
    raid = Raid.new members: members
    expect(raid.members).to eq members
  end
  it "has stand_bys" do
    stand_bys = [double, double]
    raid = Raid.new stand_bys: stand_bys
    expect(raid.stand_bys).to eq stand_bys
  end
  it "can update leader" do
    leader = double
    raid = Raid.new leader: double
    raid.leader = leader
    expect(raid.leader).to eq leader
  end

  describe "#sign_up" do
    it "can sign up new members" do
      member = double
      subject.sign_up member
      expect(subject.members).to include member
    end
    it "doesn't take more than 5 members" do
      6.times { subject.sign_up double }
      expect(subject.members.size).to eq 5
    end
    it "moves sign ups after the 5th to stand_bys" do
      6.times { subject.sign_up double }
      expect(subject.stand_bys.size).to eq 1
    end
    
    it "ensures you cant be a member and a stand by" do
      guy = double(:guy)
      4.times { subject.sign_up double }
      2.times { subject.sign_up guy }
      expect(subject.members).to include(guy)
      expect(subject.stand_bys).not_to include(guy)
    end
  end

  describe "#leave" do
    it "can remove members" do
      member = double
      raid = Raid.new members: [member]
      raid.leave(member)
      expect(raid.members).to be_empty
    end
    it "can remove stand_bys" do
      stand_by = double
      raid = Raid.new stand_bys: [stand_by]
      raid.leave(stand_by)
      expect(raid.stand_bys).to be_empty
    end
    it "backfills the first stand by" do
      4.times { subject.sign_up double }
      guy = double(:guy)
      other_guy = double(:other_guy)
      subject.sign_up guy
      subject.sign_up other_guy
      subject.sign_up double
      subject.leave(guy)
      expect(subject.members).to include other_guy
    end
  end

  describe "#leader=" do
    it "can promote a member to leader" do
      guy = double(:guy)
      raid = Raid.new members: [guy]
      raid.leader = guy
      expect(raid.members).to be_empty
    end
    it "back fills if possible when promoting member" do
      guy = double(:guy)
      raid = Raid.new members: [guy], stand_bys: [double]
      raid.leader = guy
      expect(raid.members).not_to be_empty
      expect(raid.stand_bys).to be_empty
    end
    it "can promote a stand by to leader" do
      guy = double(:guy)
      raid = Raid.new stand_bys: [guy]
      raid.leader = guy
      expect(raid.stand_bys).to be_empty
    end
  end

  it "can be converted to JSON" do
    subject.leader = "Bill"
    subject.sign_up "Fosh"
    expect(subject.to_json).to eq({name: nil, leader: "Bill", members:["Fosh"], stand_bys: []}.to_json)
  end

  it "displays its status" do
    raid = Raid.new name: "test", leader: "bill", members: ["John"], stand_bys: ["joe"]
    expect(raid.status).to eq("test - Leader: bill - Members: 2/6 - Standby: 1") 
  end
end
