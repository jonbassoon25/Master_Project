% Initialize Objects
brick = ConnectBrick('GROUP6');
driveTrain = DriveTrain(brick, 'A', 'D');
keyboard = Keyboard();
arm = Motor(brick, 'C');
manualController = ManualController(keyboard, driveTrain, arm);
% rotator = Motor(brick, 'B');
% colorSensor = ColorSensor(brick, -1);
% touchSensor = TouchSensor(brick, -1);
% ultrasonicSensor = UltrasonicSensor(brick, -1);
% rangeFinder = RangeFinder(rotator, ultrasonicSensor);
% autonomousController = AutonomousController(driveTrain, rangeFinder, colorSensor, touchSensor);

state = States.ManualControl; % Initial State

while state ~= States.Exit
    pause(0.05); % Allow keyboard to take input

    switch (state)
        case States.ManualControl
            manualController.Update()

            % Manage User Input
            if (keyboard.IsPressed("q"))
                state = States.Exit;
            elseif (keyboard.IsPressed("v"))
                manualController.Reset();
                state = States.AutonomousControl;
            end

        case States.AutonomousControl    % Autonomous Control Loop
            fprintf("Switched to Automatic Control\n");

           % Refer to Enums -> Colors for which color we want
           % autonomousController.Navigate(Colors.Blue);
            state = States.ManualControl;

        otherwise % Invalid State
            fprintf("Invalid State Encoding: %d. Defaulting to Manual Control.", state);
            state = States.ManualControl;
    end
end

clear; % Destroy all objects stored in the workspace