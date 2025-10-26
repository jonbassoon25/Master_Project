classdef AutonomousController
    % Controls the provided DriveTrain automatically with the provided sensors

    properties (Constant, Access = private)
        DEBUG logical = false % Enable/Disable debug logs
    end

    properties (Constant, Access = protected)
        MAZE_TILE_SIZE double = 12.0;                % The size of the maze tiles in cm
        TARGET_BEARING_PID PID = PID(0.05, 80, 0.2); % The target bearing PID controller. Allows the vehicle to automatically correct its bearing.
        DRIVE_VELOCITY double = 180.0                % The maximum foward velocity magnitude in cm/s
        TURNING_RATE double = 720.0                  % The maximum turning rate magnitude in deg/s
    end

    properties (Access = protected)
        targetForwardVelocity double % The current target forward velocity in cm/s
        targetAngularVelocity double % The current target angular velocity in deg/s counter clockwise
        driveTrain DriveTrain        % The drive train controlled by this controller
        rangeFinder RangeFinder      % The range finder for this controller to use
        colorSensor ColorSensor      % The color sensor for this controller to use
        touchSensor TouchSensor      % The touch sensor for this controller to use

        forwardUpdateClock % clock for determining update time
        end

    methods (Access = protected)
        function MoveForward(controller)
            % Moves the car forward while keeping it parallel to the left & right walls
            trueForwardBearing = controller.rangeFinder.GetTrueForwardBearing();
            bearingError = trueForwardBearing; % - 0

            controller.TARGET_BEARING_PID.UpdateErrorState(bearingError, toc(controller.forwardUpdateClock));
            controller.forwardUpdateClock = tic;

            controller.driveTrain.SetMixedMovementTargets(controller.DRIVE_VELOCITY, controller.TARGET_BEARING_PID.CalculateControlOutput() * controller.TURNING_RATE);
            controller.driveTrain.ManageVelocityTargets();
        end

        function TurnLeft(controller)
            % Turns the car left
            controller.driveTrain.Stop();
            controller.driveTrain.TurnLeft(90);
        end

        function TurnRight(controller)
            % Turns the car right
            controller.driveTrain.Stop();
            controller.driveTrain.TurnLeft(-90);
        end

        function TurnAround(controller)
            % Turns the car around
            controller.driveTrain.Stop();
            controller.driveTrain.TurnLeft(180);
        end
    end

    methods (Access = public)
        function controller = AutonomousController(driveTrain, rangeFinder, colorSensor, touchSensor)
            % Initializes the properties of a new AutonomousController object
            arguments (Input)
                driveTrain DriveTrain   % The drive train controlled by this controller
                rangeFinder RangeFinder % The range finder for this controller to use
                colorSensor ColorSensor % The color sensor for this controller to use
                touchSensor TouchSensor % The touch sensor for this controller to use
            end
            arguments (Output)
                controller AutonomousController
            end
            controller.driveTrain = driveTrain;
            controller.rangeFinder = rangeFinder;
            controller.colorSensor = colorSensor;
            controller.touchSensor = touchSensor;

            % Populate rangefinder scan
            controller.rangeFinder.CompleteFullScan();
        end

        function Navigate(controller, targetColor)
            % Turns on autonomous navigation. Does not return control until
            % the target color is reached.
            arguments (Input)
                controller AutonomousController % This controller object
                targetColor Colors              % The target color to look for
            end

            % Navigation Logic:
            %   -  If there is an opening on the left and/or right and/or front, turn left
            %   -  If the is an opening to the front and/or right, continue forwards
            %   -  If there is an opening on the right, turn right
            %   -  If there is no opening to the left, front, or right, turn around & move forwards
            %   -  If there is a red line at any point, stop for 2 seconds

            % Start the rangeFinder
            controller.rangeFinder.Start();

            % Check color to determine if we have reached the navigation target
            while (controller.colorSensor.GetColor() ~= targetColor) 
                % Update the rangeFinder
                controller.rangeFinder.Update();

                % Collect distance data
                distanceFront = controller.rangeFinder.GetMinDistanceForward();
                distanceLeft = controller.rangeFinder.GetMinDistanceLeft();
                distanceRight = controller.rangeFinder.GetMinDistanceRight();
                
                % Calculate navigation booleans
                wallDetectionThreshold = controller.MAZE_TILE_SIZE / 2.0;
                frontWallDetected = (distanceFront <= wallDetectionThreshold);
                leftWallDetected  = (distanceLeft  <= wallDetectionThreshold);
                rightWallDetected = (distanceRight <= wallDetectionThreshold);

                % Implement navigation logic
                if (~leftWallDetected)
                    % Turn left
                    if (controller.DEBUG) 
                        fprintf("Turning Left\n");
                    end
                    controller.TurnLeft();
                elseif (~frontWallDetected)
                    % Go forward
                    if (controller.DEBUG) 
                        fprintf("Moving Forward\n");
                    end
                    controller.MoveForward();
                elseif (~rightWallDetected)
                    % Turn right
                    if (controller.DEBUG) 
                        fprintf("Turning Right\n");
                    end
                    controller.TurnRight();
                else
                    % Turn around & go forward
                    if (controller.DEBUG) 
                        fprintf("Turning around\n");
                    end
                    controller.TurnAround();
                end

                % Stop for red bars
                if (controller.colorSensor.GetColor() == Colors.Red)
                    % Stop
                    if (controller.DEBUG) 
                        fprintf("Stopping\n");
                    end
                    
                    controller.driveTrain.Stop();

                    % Wait 2 seconds
                    timeStart = tic;
                    while (toc(timeStart) < 2.0)
                        pause(0.1);
                    end

                    % Move forward for 1 second to move past the stop bar
                    controller.driveTrain.SetForwardVelocity(controller.DRIVE_VELOCITY);
                    timeStart = tic;
                    while (toc(timeStart) < 1.0)
                        controller.driveTrain.ManageVelocityTargets();
                        pause(0.05);
                    end

                    % Reset the drive train to its default state for
                    % continued execution of the navigation loop
                    controller.driveTrain.Stop();
                end
            end
            % Ensures that the car & rangefinder stop
            controller.driveTrain.Stop();
            controller.rangeFinder.Stop();
        end
    end
end
