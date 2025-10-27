classdef DriveTrain < handle
    % The DriveTrain controls the two motors of a vehicle to perform complex manuevers
    
    properties (Constant, Access=private)
        DEBUG logical = false % Display debug information at runtime
    end

    properties (Constant, Access = protected)
        WHEEL_RADIUS double = (6.72 / 2)         % The radius of both wheels in cm
        TURNING_RADIUS double = (20.6 - 3.9) / 2 % Distance between the driveTrain's center and the points of contact of its wheels in cm
        LEFT_VELOCITY_MULTIPLIER double = 1.0    % The velocity multiplier for the left wheel
        RIGHT_VELOCITY_MULTIPLIER double = 1.0   % The velocity multiplier for the right wheel
        TURNING_ERROR_THRESHOLD double = 12.0    % The turning error threshold in degrees
    end

    properties (Access = protected)
        brick Brick      % The EV3 brick that the DriveTrain motors are connected to
        leftMotor Motor  % The Left Motor
        rightMotor Motor % The Right Motor
    end


    methods (Access = protected)
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

        function wheelRotations = DriveTrainRotationsToWheelRotations(driveTrain, degrees)
            % Converts a counter clockwise rotation of the drivetrain to
            % a counter clockwise rotation of its wheels
            arguments (Input)
                driveTrain DriveTrain % The DriveTrain Object
                degrees double        % The degrees counter clockwise that the drivetrain is rotating
            end
            arguments (Output)
                wheelRotations double % The converted degrees counter clockwise that the wheels must rotate
            end
            wheelRotations = degrees * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS);
        end
    end

    methods (Access = public)
        function driveTrain = DriveTrain(brick, leftMotorPort, rightMotorPort)
            % Initializes the properties of a new DriveTrain object
            arguments (Input)
                brick Brick % The EV3 brick that the DriveTrain motors are connected to
                leftMotorPort char  % The motor port letter of the left wheel's motor
                rightMotorPort char % The motor port letter of the right wheel's motor
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
            if (driveTrain.DEBUG) 
                fprintf("Turning Left %.2f degrees\n", degreesCounterClockwise);
            end
            driveTrain.leftMotor.SetRelAngleTarget(degreesCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS));
            driveTrain.rightMotor.SetRelAngleTarget(-degreesCounterClockwise * (driveTrain.TURNING_RADIUS / driveTrain.WHEEL_RADIUS));
            
            % Calculate initial error values
            leftError = abs(driveTrain.leftMotor.GetCurrentAngleTarget() - driveTrain.leftMotor.GetCurrentAngle());
            rightError = abs(driveTrain.rightMotor.GetCurrentAngleTarget() - driveTrain.rightMotor.GetCurrentAngle());
            while (leftError >= driveTrain.TURNING_ERROR_THRESHOLD || rightError >= driveTrain.TURNING_ERROR_THRESHOLD) 
                if (driveTrain.DEBUG)
                    fprintf("Left Wheel Turning Error: %.2f\n", leftError);
                    fprintf("Right Wheel Turning Error: %.2f\n", rightError);
                    fprintf("Error Threshold: %f\n", driveTrain.TURNING_ERROR_THRESHOLD);
                end

                % Manage wheel angles
                driveTrain.leftMotor.ManageSetTargets();
                driveTrain.rightMotor.ManageSetTargets();
                
                % Recalculate error values
                leftError = abs(driveTrain.leftMotor.GetCurrentAngleTarget() - driveTrain.leftMotor.GetCurrentAngle());
                rightError = abs(driveTrain.rightMotor.GetCurrentAngleTarget() - driveTrain.rightMotor.GetCurrentAngle());
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

            if (driveTrain.DEBUG)
                fprintf("Setting a forward velocity of %f cm/s\n", targetVelocity);
                fprintf("Calculated wheel velocity: %f deg/sec\n", targetAVal);
            end
        end

        function vel = GetForwardVelocity(driveTrain)
            arguments (Output)
                vel double
            end
            vel = (driveTrain.leftMotor.GetCurrentVelocityTarget() + driveTrain.rightMotor.GetCurrentVelocityTarget()) ^ (0.5);
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
            leftMotorTargetAngularVelocity = driveTrain.VelocityToAngularVelocity(forwardVelocity) - driveTrain.DriveTrainRotationsToWheelRotations(angularVelocityCounterClockwise);
            rightMotorTargetAngularVelocity = driveTrain.VelocityToAngularVelocity(forwardVelocity) + driveTrain.DriveTrainRotationsToWheelRotations(angularVelocityCounterClockwise);
        
            if (driveTrain.DEBUG)
                fprintf("Setting a mixed movement target of %.2f cm/s forward and %.2f deg/s counter clockwise\n", forwardVelocity, angularVelocityCounterClockwise);
                fprintf("Calculated motor velocities A: %.2f deg/s and D: %.2f deg/s\n", leftMotorTargetAngularVelocity, rightMotorTargetAngularVelocity);
            end

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
                brake = 0
            end
            driveTrain.leftMotor.Stop(brake);
            driveTrain.rightMotor.Stop(brake);
        end
    end
end