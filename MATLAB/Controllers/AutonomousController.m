classdef AutonomousController
    % Controls the provided DriveTrain automatically with the provided sensors

    properties (Constant, Access = private)
        DEBUG logical = false % Enable/Disable debug logs
    end

    properties (Constant, Access = protected)
        MAZE_TILE_SIZE double = 12.0; % The size of the maze tiles in cm
        TARGET_BEARING_PID PID = PID(0.05, 80, 0.2); % The target bearing PID controller. Allows the vehicle to automatically correct its bearing.
        FORWARD_ACCELERATION double = 36.0  % The forward acceleration constant in cm/s²
        ANGULAR_ACCELERATION double = 120.0 % The angular acceleration constant in deg/s² counter clockwise
        ARM_ACCELERATION double = 120.0     % The angular acceleration constnt in deg/s² counter clockwise
        MAX_DRIVE_VELOCITY double = 180.0   % The maximum foward velocity magnitude in cm/s
        MAX_TURNING_RATE double = 720.0     % The maximum turning rate magnitude in deg/s
    end

    properties (Access = protected)
        targetForwardVelocity double % The current target forward velocity in cm/s
        targetAngularVelocity double % The current target angular velocity in deg/s counter clockwise
        driveTrain DriveTrain   % The drive train controlled by this controller
        rangeFinder RangeFinder % The range finder for this controller to use
        colorSensor ColorSensor % The color sensor for this controller to use
        touchSensor TouchSensor % The touch sensor for this controller to use

        relativeTargetBearing double % The bearing of the true forward direction relative to the direction of the drivetrain
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
            controller.targetForwardVelocity = controller.targetForwardVelocity + controller.FORWARD_ACCELERATION;
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.MangageVelocityTargets();
            
        end
        function TurnRight(controller)
            controller.targetAngularVelocity = controller.targetAngularVelocity - controller.ANGULAR_ACCELERATION;
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
        end
        function TurnLeft(controller)
            controller.targetAngularVelocity = controller.targetAngularVelocity + controller.ANGULAR_ACCELERATION;
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

            controller.relativeTargetBearing = 0.0;
        end

        function Navigate(controller, targetColor)
            % Turns on autonomous navigation. Does not return control until
            % the target color is reached.
            arguments (Input)
                targetColor Colors % The target color to look for
            end

            %Loop checking color
            while (colorSensor.GetColor() ~= targetColor) 

                if distanceFront < controller.MAZE_TILE_SIZE / 2.0 % Threshold for wall detection
                    % Check right
                    if (controller.ShouldTurnLeft)
                        TurnLeft(); 
                    elseif (controller.ShouldTurnRight())
                        TurnRight(); 
    
                    elseif (controller.ShouldStop())
                        Stop();
                    else
                        % No valid moves
                    end
                else
                    MoveForward(); % Implement moveForward function
                end
                
            end
                % Ensures Car Stops
                controller.driveTrain.Stop();
        end
    end
end
