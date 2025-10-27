% Initialize Objects
brick = ConnectBrick('GROUP6');
driveTrain = DriveTrain(brick, 'A', 'D');
keyboard = Keyboard();
arm = Motor(brick, 'C');
manualController = ManualController(keyboard, driveTrain, arm);
rotator = Motor(brick, 'B');
colorSensor = ColorSensor(brick, 4);
touchSensor = TouchSensor(brick, 1);
ultrasonicSensor = UltrasonicSensor(brick, 3);
rangeFinder = RangeFinder(rotator, driveTrain, ultrasonicSensor);
autonomousController = AutonomousController(driveTrain, rangeFinder, colorSensor, touchSensor);

state = States.ManualControl; % Initial State

autonomousTargetLocations = Queue(); % A queue for the locations that the autonomous controller should navigate to
autonomousTargetLocations.Enqueue(Colors.Blue);   % Location #1
autonomousTargetLocations.Enqueue(Colors.Yellow); % Location #2

while state ~= States.Exit
    pause(0.05); % Allow keyboard to take input
    switch (state)
        case States.ManualControl
            manualController.Update()

            % Manage User Input
            if (keyboard.IsPressed("q"))
                state = States.Exit;
            elseif (keyboard.IsPressed("v"))
                fprintf("Switching to Automatic Control...\n");
                manualController.Reset();
                fprintf("1\n");
                state = States.AutonomousControl;
                fprintf("2\n");
            end

        case States.AutonomousControl
            fprintf("Switched to Automatic Control.\n");

            % This check occurs only as autonomous control is entered
            if (autonomousTargetLocations.length == 0)
                fprintf("WARNING: No defined next location. Automatic control cannot activate.\n")
            else
                % Navigate to the next location in the navigation queue
                autonomousController.Navigate(autonomousTargetLocations.Dequeue());
                fprintf("The target location was reached.\n");
            end
                
            % Return control to the user
            fprintf("Returning to Manual Control.\n")
            state = states.ManualControl;
            
        otherwise % Invalid State
            fprintf("Invalid State. Defaulting to Manual Control.\n");
            state = States.ManualControl;
    end
end

driveTrain.Stop();
arm.Stop();
rangeFinder.Stop();
clear; % Destroy all objects stored in the workspace
