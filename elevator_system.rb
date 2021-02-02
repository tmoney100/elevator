class ElevatorSystem

  def initialize(elevators: 1, floors: 2)
    @elevators = elevators
    @floors = floors
  end

  def execute_demo
    p "Starting Demo"
    p "Elevators #{@elevators}"
    p "Floors #{@floors}"

    p "End of Demo"
  end

end