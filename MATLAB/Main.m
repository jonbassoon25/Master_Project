% Initialize Objects
brick = ConnectBrick('GROUP6');
driveTrain = DriveTrain(brick, 'A', 'D');
keyboard = Keyboard();
arm = Motor(brick, 'C');
manualController = ManualController(keyboard, driveTrain, arm);


% State Encodings
%   0 = Manual Control
%   1 = Autonomous Control
%   2 = End
state = 0; % Initial State


while state ~= 2
    pause(0.05); % Allow keyboard to take input

    switch (state)
        case 0    % Manual Control Loop
            manualController.Update()

            % Manage User Input
            if (keyboard.IsPressed("q"))
                state = 2;
            elseif (keyboard.IsPressed("v"))
                manualController.Reset();
                state = 1;
            end

        case 1    % Autonomous Control Loop
            fprintf("Switched to Automatic Control\n");
            state = 0;

        otherwise % Invalid State
            fprintf("Invalid State Encoding: %d. Defaulting to Manual Control.", state);
            state = 0;
    end
end

clear; % Destroy all objects stored in the workspace