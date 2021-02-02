require 'rspec/autorun'

require_relative 'elevator_system'

describe ElevatorSystem do
  it "initializes" do
      es = ElevatorSystem.new
      expect(es).to be_a ElevatorSystem
  end
end