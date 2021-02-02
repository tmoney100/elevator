require_relative "elevator_system"

elevator_system = ElevatorSystem.new(elevators: 3, floors: 8)
elevator_system.execute_demo
