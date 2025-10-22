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
        function bool = ShouldTurnLeft(controller) % TODO: Implement ShouldTurnLeft function
            bool = false;
        end
        function bool = ShouldTurnRight(controller) % TODO: Implement ShouldTurnRight function
            bool = false;
        end

        function MoveForward(controller) % TODO: Implement MoveForward function
        controller.driveTrain.SetMixedMovementTargets(controller.targetForwardsVelocity, controller.targetAngularVelociity);
        controller.driveTrain.MangageVelocityTargets();
        end
        function TurnRight(controller)
        controller.driveTrain.SetMixedMovementTargets(controller.targetForwardsVelocity, controller.targetAngularVelocity);
        controller.driveTrain.ManageVelocityTargets();
        end
        function TurnLeft(controller)
        controller.driveTrain.SetMixedMovementTargets(controller.targetForwardsVelocity, controller.targetAngularVelocity);
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

            % Autonomous control logic, derived from Sophia's 'autonomous control' file
            if distanceFront < controller.MAZE_TILE_SIZE / 2.0 % Threshold for wall detection
                % Check right
                if (controller.ShouldTurnLeft)
                    TurnLeft();
                elseif (controller.ShouldTurnRight())
                    TurnRight(); % Implement TurnRight function
                else
                    % No valid moves
                end
            else
                MoveForward(); % Implement moveForward function
            end
        end
    end
end
