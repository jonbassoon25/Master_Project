classdef DriveTrain < handle
    % The DriveTrain controls the two motors of a vehicle to perform complex manuevers
    
    properties (Constant, Access = protected)
        WHEEL_RADIUS double = 1.5              % The radius of both wheels in cm
        TURNING_RADIUS double = 7.0            % Distance between the driveTrain's center and the points of contact of its wheels in cm
        LEFT_VELOCITY_MULTIPLIER double = 1.0  % The velocity multiplier for the left wheel
        RIGHT_VELOCITY_MULTIPLIER double = 1.0 % The velocity multiplier for the right wheel
        TURNING_ERROR_THRESHOLD double = 2     % The turning error threshold in degrees
    end

    properties (Access = protected)
        brick Brick      % The EV3 brick that the DriveTrain motors are connected to
        leftMotor Motor  % The Left Motor
        rightMotor Motor % The Right Motor
    end


    methods (Access = private)
        function angularVel = VelocityToAngularVelocity(driveTrain, velocity)
            % Converts a velocity to an angular velocity
            arguments (Input)
                driveTrain DriveTrain % The DriveTrain Object
                velocity double       % The velocity to convert in cm/s
            end
            arguments (Output)
                angularVel double % The converted angular velocity in deg/sec
            end
            angularVel = 180/pi * (velocity / driveTrain.WHEEL_RADIUS);
        end
    end

    methods (Access = public)
        function driveTrain = DriveTrain(brick, leftMotorPort, rightMotorPort)
            % Initializes the properties of a new DriveTrain object
            arguments (Input)
                brick Brick % The EV3 brick that the DriveTrain motors are connected to
                leftMotorPort string  % The motor port letter of the left wheel's motor
                rightMotorPort string % The motor port letter of the right wheel's motor
            end
            arguments (Output)
                driveTrain DriveTrain % The constructed DriveTrain object
            end
            driveTrain.brick = brick;
            driveTrain.leftMotor = Motor(brick, leftMotorPort);
            driveTrain.rightMotor = Motor(brick, rightMotorPort);
        end

        function TurnLeft(driveTrain, degreesCounterClockwise)
            % Turns Left in place by the specified number of degrees
            arguments (Input)
                driveTrain DriveTrain          % The DriveTrain Object
                degreesCounterClockwise double % The number of degrees counter clockwise (left) to turn
            end
            driveTrain.leftMotor.SetRelAngleTarget(degreesCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS));
            driveTrain.rightMotor.SetRelAngleTarget(-degreesCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS));
            
            % Manage wheel angles until the error threshold is met
            while (abs(driveTrain.leftMotor.GetCurrentAngleTarget() - driveTrain.leftMotor.GetCurrentAngle()) >= driveTrain.TURNING_ERROR_THRESHOLD || abs(driveTrain.rightMotor.GetCurrentAngleTarget() - driveTrain.rightMotor.GetCurrentAngle()) >= driveTrain.TURNING_ERROR_THRESHOLD) 
                driveTrain.leftMotor.ManageSetTargets();
                driveTrain.leftMotor.ManageSetTargets();
            end
        end

        function TurnRight(driveTrain, degreesClockwise)
            % Turns Right in place by the specified number of degrees
            arguments (Input)
                driveTrain DriveTrain   % The DriveTrain Object
                degreesClockwise double % The number of degrees clockwise (right) to turn
            end
            driveTrain.TurnLeft(-degreesClockwise);
        end

        function SetForwardVelocity(driveTrain, targetVelocity)
            % Sets the forward target velocity
            arguments (Input)
                driveTrain DriveTrain % The DriveTrain Object
                targetVelocity double % The new forward velocity in cm/s
            end
            targetAVal = driveTrain.VelocityToAngularVelocity(targetVelocity);
            driveTrain.leftMotor.SetVelocityTarget(targetAVal * driveTrain.LEFT_VELOCITY_MULTIPLIER);
            driveTrain.rightMotor.SetVelocityTarget(targetAVal * driveTrain.RIGHT_VELOCITY_MULTIPLIER);
        end

        function SetBackwardVelocity(driveTrain, targetVelocity)
            % Sets the backward target velocity
            arguments (Input)
                driveTrain DriveTrain % The DriveTrain Object
                targetVelocity double % The new backward velocity in cm/s
            end
            driveTrain.SetForwardVelocity(-targetVelocity);
        end

        function SetMixedMovementTargets(driveTrain, forwardVelocity, angularVelocityCounterClockwise)
            % Sets mixed movement target velocities in cm/s
            arguments (Input)
                driveTrain DriveTrain                  % This DriveTrain Object
                forwardVelocity double                 % The new forward velocity in cm/s
                angularVelocityCounterClockwise double % The new angular velocity counter clockwise (left) in deg/s
            end

            % Calculate target velocities
            leftMotorTargetAngularVelocity = driveTrain.VelocityToAngularVelocity(forwardVelocity) + angularVelocityCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS);
            rightMotorTargetAngularVelocity = driveTrain.VelocityToAngularVelocity(forwardVelocity) - angularVelocityCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS);
        
            % Set target velocities
            driveTrain.leftMotor.SetVelocityTarget(leftMotorTargetAngularVelocity * driveTrain.LEFT_VELOCITY_MULTIPLIER);
            driveTrain.rightMotor.SetVelocityTarget(rightMotorTargetAngularVelocity * driveTrain.RIGHT_VELOCITY_MULTIPLIER);
        end

        function ManageVelocityTargets(driveTrain)
            % Manages the motor velocities to match their set targets
            arguments (Input)
                driveTrain DriveTrain % This DriveTrain Object
            end
            driveTrain.leftMotor.ManageSetTargets();
            driveTrain.rightMotor.ManageSetTargets();
        end

        function Stop(driveTrain, brake)
            % Stops both wheel motors
            arguments
                driveTrain DriveTrain
                brake string = "coast"
            end
            driveTrain.leftMotor.Stop(brake);
            driveTrain.rightMotor.Stop(brake);
        end
    end
end