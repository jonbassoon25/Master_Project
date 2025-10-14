% Initialize Objects
brick = ConnectBrick('GROUP6');
driveTrain = DriveTrain(brick, "A", "D");
keyboard = Keyboard();
manualController = ManualController(keyboard, driveTrain);

state = 0; % 0 = Manual Control, 1 = Autonomous Control, 2 = End


while state ~= 2
    switch (state)
        case 0    % Manual Control Loop
            manualController.Update()

            % Manage User Input
            if (keyboard.IsPressed("esc"))
                state = 2;
            elseif (keyboard.IsPressed("r"))
                state = 1;
            end
        case 1    % Autonomous Control Loop
            fprintf("Switched to Automatic Control\n");
            state = 0;
    end
end

clear;