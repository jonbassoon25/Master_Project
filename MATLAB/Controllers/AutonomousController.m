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

        trueForwardBearing double % The bearing of the true forward direction relative to the direction of the drivetrain
    end

    methods (Access = protected)

        function bool = ShouldStop(controller)     % TODO: Implement ShouldStop function
            bool = false;
        end

        function bool = ShouldTurnLeft(controller) % TODO: Implement ShouldTurnLeft function
            bool = false;
        end
        function bool = ShouldTurnRight(controller)% TODO: Implement ShouldTurnRight function
            bool = false;
        end
        
        function Stop(controller)
            controller.driveTrain.Stop();
        end
        function MoveForward(controller)
            % Moves the car forward while keeping it parallel to the left & right walls

            
            % Temporary code
            controller.targetForwardVelocity = controller.DRIVE_VELOCITY;
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.MangageVelocityTargets();
        end
        function TurnRight(controller)
            % Turns the car through the middle of a detected opening on the right
            % This function does not return control until the turn is complete


            % Temporary code
            controller.targetAngularVelocity = -controller.TURNING_RATE;
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
        end
        function TurnLeft(controller)
            % Turns the car through the middle of a detected opening on the left
            % This function does not return control until the turn is complete


            % Temporary code
            controller.targetAngularVelocity = controller.TURNING_RATE;
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
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

            % Get the initial true forward bearing value
            controller.trueForwardBearing = controller.rangeFinder.GetTrueForwardBearing();
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
                distanceFront = controller.rangeFinder.GetMinDistanceBearing(0.0, false);
                distanceLeft = controller.rangeFinder.GetMinDistanceBearing(-90.0, false);
                distanceRight = controller.rangeFinder.GetMinDistanceBearing(90.0, false);
                
                % Calculate navigation booleans
                wallDetectionThreshold = controller.MAZE_TILE_SIZE / 2.0;
                frontWallDetected = (distanceFront <= wallDetectionThreshold);
                leftWallDetected  = (distanceLeft  <= wallDetectionThreshold);
                rightWallDetected = (distanceRight <= wallDetectionThreshold);

                % Implement navigation logic
                if (~leftWallDetected)
                    % Turn left
                elseif (~frontWallDetected)
                    % Go forward
                elseif (~rightWallDetected)
                    % Turn right
                else
                    % Turn around & go forward
                end

                % Stop for red bars
                if (controller.colorSensor.GetColor() == Colors.Red)
                    % Stop
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
