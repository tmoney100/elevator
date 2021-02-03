
class Elevator

  # Instance Variables Used:
  # floors                    = total number of floors, 2 min.
  # current_floor             = current floor the elevator is on
  # current_direction_status  = primary direction of elevator travel. This is used to prioritize order of floor stopping. 
  # floor_request_queue       = Hash keeping track of current floor requests.
  # verbose                   = used to print various step elevator is taking.
  
  # TODOS:
  # moving_status              = shows if elevator is moving
  # 
  def initialize(floors: 2, verbose: false)
    @floors = [floors, 2].max
    @current_floor = 1
    @current_direction_status = DIRECTION_STATUS[:up]
    @floor_request_queue = {}
    # TIP: If @verbose is set to true the elevator will "puts" information about each step its taking.
    @verbose = false
    
    # TODO: add to add more life-like elevator attrs.
    # @moving_status = false
    # TODO: Add 'door status' for more life-like elevator attrs.
    # @current_door_status = DOOR_STATUS[:closed]
  end

  attr_reader :floors, :current_floor, :current_direction_status
  attr_accessor :verbose

  # Enum-like - Possible states of @current_direction_status
  DIRECTION_STATUS = {
    up: :up,
    down: :down,
  }

  # TODO: Add 'door status' for more life-like elevator
  # DOOR_STATUS = {
  #   opened: :opened,
  #   closed: :closed,
  #   opening: :opening,
  #   closing: :closing,
  # }

  # request
  # Interface function for user to make a request to the floor. 
  # 
  # @returns Integer | false
  # false - invalid floor
  # Integer - floor successfully added to queue
  def request(floor:)
    return false unless valid_floor?(floor)

    add_floor_to_queue(floor)
    execute_move_to_next_floor!

    floor
  end

  private

  # execute_move_to_next_floor!
  # Changes elevator state to reflect move to new floor.
  # As system developrs this will involve closing doors, setting timers to
  # reflect time to move, etc.
  # 
  # @argument Integer - floor
  # @return   Integer - floor
  def execute_move_to_next_floor!
    say ""
    say "Executing Move"
    say "Current floor is #{@current_floor}"
    say "Current direction is #{@current_direction_status}"
    say "Next floor is #{next_floor}"
    say "Current Queue Above is #{queued_floors_above}"
    say "Current Queue Below is #{queued_floors_below}"

    current_next_floor = next_floor
    while @current_floor != current_next_floor
      if @current_direction_status.eql?(DIRECTION_STATUS[:up])
        move_up!
      else # DIRECTION_STATUS[:down]
        move_down!
      end

      @floor_request_queue[@current_floor] = false
    end

    conditionally_change_move_direction!

    say "Welcome to floor #{@current_floor}"
    say "End of Execute Move"
    @current_floor
  end

  # conditionally_change_move_direction!
  # Will look at current position and queue to determine if move direction should change.
  # 
  # BUG/TODO:
  # We need to keep track of time of request, not just the boolean.
  # This way we can prioritize move direction based on time. 
  # 
  # @return Boolean - True if direction changed. false if no direction changed.
  # 
  def conditionally_change_move_direction!
    if @current_direction_status.eql?(DIRECTION_STATUS[:up])
      if queued_floors_above.length > 0
        return false
      else
        @current_direction_status = DIRECTION_STATUS[:down]
        return true
      end
    else # DIRECTION_STATUS[:down]
      if queued_floors_below.length > 0
        return false
      else
        @current_direction_status = DIRECTION_STATUS[:up]
        return true
      end
    end
  end

  # current_floor_queue
  # 
  # @arguments -none-
  # @return [Integer] - Array of floors in current queue
  # 
  def current_floor_queue
    @floor_request_queue.keys.filter {|key| @floor_request_queue[key] }.sort
  end

  # next_floor
  # Returns the floor [Integer] that the elevator will stop at (@current_floor) next.
  # Returns current floor if no requests (current_floor_queue) are there.
  # @arguments -none-
  # @returns   Integer
  def next_floor
    return @current_floor if current_floor_queue.empty?

    floors_requested_in_proper_direction.first
  end

  # move_up
  #   Adds sleep to act as if elevator was moving. Increments current_floor state.
  # @return Integer = new @current_floor
  def move_up!
    return @current_floor if current_floor_at_max

    say "Moving up to #{@current_floor}!"
    sleep(0.1)
    @current_floor += 1
    @current_floor
  end

  # move_down
  #   Adds sleep to act as if elevator was moving. Decrements current_floor state.
  # @return Integer = new @current_floor  
  def move_down!
    return @current_floor if current_floor_at_min

    say "Moving down to #{@current_floor}!"
    sleep(0.1)
    @current_floor -= 1
    @current_floor
  end

  # floors_requested_in_proper_direction
  # Find the floors that are requested in the direction the elevator is going.
  # Ex. Current floor is 3, elevator is going up, all floors will be above 3.
  # 
  # NOTE: current_floor is never included in list. 
  # 
  # @arguments -none-
  # @return    [Integer] - Array of Floors (Integer)
  def floors_requested_in_proper_direction
    if @current_direction_status.eql?(DIRECTION_STATUS[:up])
      queued_floors_above
    else # i.e. @current_direction_status.eql?(DIRECTION_STATUS[:down])
      queued_floors_below
    end
  end

  def queued_floors
    @floor_request_queue.keys.keep_if {|key| @floor_request_queue[key] }
  end

  def queued_floors_above
    queued_floors.keep_if {|flr| flr > @current_floor }.sort
  end

  def queued_floors_below
    queued_floors.keep_if {|flr| flr < @current_floor }.sort.reverse
  end

  # floors_requested_in_proper_direction
  # Find the floors that are requested in the direction the elevator is going.
  # Ex. Current floor is 3, elevator is going up, all floors will be added below 3.
  # @arguments -none-
  # @return    [Integer] - Array of Floors (Integer)
  def floors_requested_in_anti_direction
    if @current_direction_status.eql?(DIRECTION_STATUS[:up])
      queued_floors_below
    else # i.e. @current_direction_status.eql?(DIRECTION_STATUS[:down])
      queued_floors_above
    end
  end

  # add_floor_to_queue
  # 
  # @argument Integer - Floor #
  # @return   Integer - Floor #
  def add_floor_to_queue(floor)
    say "Adding floor to queue: #{floor}"
    @floor_request_queue[floor] = true
    floor
  end

  def valid_floor?(floor)
    floor.positive? && floor <= @floors 
  end

  def say(text)
    return true unless @verbose
    p text
  end

  def current_floor_at_max
    @current_floor == @floors
  end

  def current_floor_at_min
    @current_floor == 1  
  end
end