require "set"
require "json"

class Raid
  attr_reader :name, :leader, :members, :stand_bys
  def initialize(name: nil, leader: nil, members: [], stand_bys: [])
    @name = name
    @leader = leader
    @members = Set.new members
    @stand_bys = Set.new stand_bys
  end

  def leader=(leader)
    if @members.include?(leader)
      @members.delete(leader)
      if @stand_bys.size > 0
        backfill
      end
    elsif @stand_bys.include?(leader)
      @stand_bys.delete(leader)
    end
    @leader = leader
  end

  def sign_up(member)
    return if @members.size == 5 && @members.include?(member)
    unless @members.size == 5 
      @members << member
    else
      @stand_bys << member
    end
  end

  def leave(member)
    @members.delete(member)
    @stand_bys.delete(member)
    if @members.size < 5 && @stand_bys.size > 0
      backfill
    end
  end

  def members
    @members.to_a
  end

  def stand_bys
    @stand_bys.to_a
  end

  def to_json
    {name: @name, leader: @leader, members: @members.to_a, stand_bys: @stand_bys.to_a}.to_json
  end

private
  def backfill
    member = @stand_bys.to_a.first
    @stand_bys.delete(member)
    @members << member
  end
end
