classdef AutonomousController
    % Controls the provided DriveTrain automatically with the provided sensors

    properties (Constant, Access = private)
        DEBUG logical = false % Enable/Disable debug logs
    end

    properties (Constant, Access = protected)
        MAZE_TILE_SIZE double = 12.0; % The size of the maze tiles in cm
        TARGET_BEARING_PID PID = PID(0.05, 80, 0.2); % The target bearing PID controller. Allows the vehicle to automatically correct its bearing.
    end

    properties (Access = protected)
        driveTrain DriveTrain   % The drive train controlled by this controller
        rangeFinder RangeFinder % The range finder for this controller to use
        colorSensor ColorSensor % The color sensor for this controller to use

        relativeTargetBearing double % The bearing of the true forward direction relative to the direction of the drivetrain
    end

    methods (Access = protected)
        function bool = ShouldTurnLeft(controller)
            bool = false;
        end
        function bool = ShouldTurnRight(controller)
            bool = false;
        end

        function MoveForward(controller)
        end
        
    end

    methods (Access = public)
        function controller = AutonomousController(driveTrain, rangeFinder, colorSensor)
            % Initializes the properties of a new AutonomousController object
            arguments (Input)
                driveTrain DriveTrain   % The drive train controlled by this controller
                rangeFinder RangeFinder % The range finder for this controller to use
                colorSensor ColorSensor % The color sensor for this controller to use
            end
            arguments (Output)
                controller AutonomousController
            end
            controller.driveTrain = driveTrain;
            controller.rangeFinder = rangeFinder;
            controller.colorSensor = colorSensor;

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