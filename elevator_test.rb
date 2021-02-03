require 'rspec/autorun'

require_relative 'elevator'

describe Elevator do
  before(:each) do
    @floors = 6
    @es = es = Elevator.new(floors: @floors)
  end
  
  after(:each) do
    @es.instance_variable_set(:@current_floor, 1)
    @es.instance_variable_set(:@current_direction_status, Elevator::DIRECTION_STATUS[:up])
    @es.instance_variable_set(:@floor_request_queue, {})
  end

  it "initializes" do
    expect(@es).to be_a Elevator
  end

  # NOTE: You'll note i'm making tests on private methods.
  # Some may not like this practice as they like to test interfaces
  # not the details behind the interface.
  # I can see their point. but I'd like to disagree.
  # I think tests should test complexity and private/implementation
  # methods can be complex. If there weren't complexity we wouldn't need tests,
  # it's not the interface that matter for testing, in this opinion, it's the complexity
  # that needs to be validated.
  it "can #move_up!" do
    new_current_floor = @es.send(:move_up!)
    expect(new_current_floor).to eql(2)

    # Check that you can't go over max
    10.times { new_current_floor = @es.send(:move_up!) }
    expect(new_current_floor).to eql(@floors)
  end

  # NOTE: This test is overloaded. We could separate them
  # into two different tests, if we didn't have 2 hrs to code ;)
  it "can #move_down!" do
    # Check that you can't go below 1st floor
    new_current_floor = @es.send(:move_down!)
    expect(new_current_floor).to eql(1)
  
    @es.send(:move_up!) # 2
    @es.send(:move_up!) # 3
    @es.send(:move_up!) # 4
    new_current_floor =  @es.send(:move_down!)
    expect(new_current_floor).to eql(3)
  end

  # NOTE: again testing overload here. (due to time)
  it "can #add_floor_to_queue & #floors_requested #floors_requested_in_proper_direction & floors_requested_in_anti_direction" do
    # prep for tests
    @es.send(:move_up!) # 2
    @es.send(:move_up!) # 3

    @es.send(:add_floor_to_queue, 3)
    expect(@es.send(:current_floor_queue)).to include(3) 
    expect(@es.send(:floors_requested_in_proper_direction).length).to eql(0)
    expect(@es.send(:floors_requested_in_anti_direction).length).to eql(0)

    @es.send(:add_floor_to_queue, 1)
    expect(@es.send(:current_floor_queue)).to include(3)
    expect(@es.send(:current_floor_queue)).to include(1)
    expect(@es.send(:floors_requested_in_proper_direction).length).to eql(0)
    expect(@es.send(:floors_requested_in_anti_direction).length).to eql(1)

    @es.send(:add_floor_to_queue, 6)
    expect(@es.send(:current_floor_queue)).to include(3)
    expect(@es.send(:current_floor_queue)).to include(1)
    expect(@es.send(:current_floor_queue)).to include(6)
    expect(@es.send(:floors_requested_in_proper_direction).length).to eql(1)
    expect(@es.send(:floors_requested_in_anti_direction).length).to eql(1)
  end

  it "can #execute_move_to_next_floor!" do
    # @es.verbose = true

    @es.send(:add_floor_to_queue, 6)
    @es.send(:execute_move_to_next_floor!)

    expect(@es.send(:current_floor)).to eql(6)
    expect(@es.send(:next_floor)).to eql(6)
    expect(@es.send(:current_floor_queue).length).to eql(0)

    @es.send(:add_floor_to_queue, 3)
    @es.send(:add_floor_to_queue, 1)
    @es.send(:add_floor_to_queue, 5)
    expect(@es.send(:current_floor_queue).length).to eql(3)

    expect(@es.send(:next_floor)).to eql(5)
    @es.send(:execute_move_to_next_floor!)
    expect(@es.send(:current_floor)).to eql(5)
    
    expect(@es.send(:next_floor)).to eql(3)
    @es.send(:execute_move_to_next_floor!)
    expect(@es.send(:current_floor)).to eql(3)
    
    expect(@es.send(:next_floor)).to eql(1)
    @es.send(:execute_move_to_next_floor!)
    expect(@es.send(:current_floor)).to eql(1)

  end

end