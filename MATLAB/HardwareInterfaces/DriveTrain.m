classdef DriveTrain < handle
    % The drivetrain of the vehicle
    %   This controlls the two motors on the vechicle to
    %   perform complex manuvers

    properties (Access = protected)
        % Hardware variable references
        brick
        leftMotor
        rightMotor
        wheelRadius
        turningRadius % Distance between the points of contact of the 2 turning wheels
        leftVelocityMultiplier
        rightVelocityMultiplier
        turningError
        
    end


    methods (Access = private)
        function angularVel = VelocityToAngluarVelocity(driveTrain, velocity)
            % Converts a velocity in cm/sec to an angular velocity in
            %   degrees per second
            angularVel = 180/pi * (velocity / driveTrain.wheelRadius);
        end
    end


    methods (Access = public)
        function driveTrain = DriveTrain(brick, leftMotorPort, rightMotorPort)
            %Construct an instance of this class

            % Set hardware variables
            driveTrain.brick = brick;
            driveTrain.leftMotor = Motor(brick, leftMotorPort);
            driveTrain.rightMotor = Motor(brick, rightMotorPort);

            driveTrain.wheelRadius = (3.0) / 2; % find actual value
            driveTrain.leftVelocityMultiplier = 1.0; % find actual value
            driveTrain.rightVelocityMultiplier = 1.0; % find actual value
            driveTrain.turningRadius = (14.0) / 2; % find actual value
            driveTrain.turningError = 2; % find actual value
        end

        function TurnLeft(driveTrain, degreesCounterClockwise)
            % Turns Left in place by the specified number of degrees
            driveTrain.leftMotor.SetRelAngleTarget(degreesCounterClockwise * (driveTrain.turningRadius / driveTrain.wheelRadius));
            driveTrain.rightMotor.SetRelAngleTarget(-degreesCounterClockwise * (driveTrain.turningRadius / driveTrain.wheelRadius));
            % Managing Angles 
            while (abs(driveTrain.leftMotor.GetCurrentAngleTarget() - driveTrain.leftMotor.GetCurrentAngle()) >= driveTrain.turningError || abs(driveTrain.rightMotor.GetCurrentAngleTarget() - driveTrain.rightMotor.GetCurrentAngle()) >= driveTrain.turningError) 
                driveTrain.leftMotor.ManageSetTargets();
                driveTrain.leftMotor.ManageSetTargets();
            end
        end

        function TurnRight(driveTrain, degreesClockwise)
            % Turns Right in place by the specified number of degrees
            driveTrain.TurnLeft(-degreesClockwise);
        end

        function SetForwardVelocity(driveTrain, targetVelocity)
            % Sets this drivetrain's forward target velocity in cm/s
            targetAVal = driveTrain.VelocityToAngluarVelocity(targetVelocity);
            driveTrain.leftMotor.SetVelocityTarget(targetAVal * driveTrain.leftVelocityMultiplier);
            driveTrain.rightMotor.SetVelocityTarget(targetAVal * driveTrain.rightVelocityMultiplier);
        end

        function SetBackwardVelocity(driveTrain, targetVelocity)
            % Sets this drivetrain's backward target velocity in cm/s
            driveTrain.SetForwardVelocity(-targetVelocity);
        end

        function SetMixedMovementTargets(driveTrain, forwardVelocity, angularVelocityCounterClockwise)
            % Sets mixed movement target velocities in cm/s
            leftMotorTargetAngularVelocity = driveTrain.VelocityToAngluarVelocity(forwardVelocity) + angularVelocityCounterClockwise * (driveTrain.turningRadius / driveTrain.wheelRadius);
            rightMotorTargetAngularVelocity = driveTrain.VelocityToAngluarVelocity(forwardVelocity) - angularVelocityCounterClockwise * (driveTrain.turningRadius / driveTrain.wheelRadius);
        
            driveTrain.leftMotor.SetVelocityTarget(leftMotorTargetAngularVelocity * driveTrain.leftVelocityMultiplier);
            driveTrain.rightMotor.SetVelocityTarget(rightMotorTargetAngularVelocity * driveTrain.rightVelocityMultiplier);
        end

        function ManageVelocityTargets(driveTrain)
            % Manages the forward velocity to match the set target
            driveTrain.leftMotor.ManageSetTargets();
            driveTrain.rightMotor.ManageSetTargets();
        end

        function Stop(driveTrain, brake)
            % Stops both driveTrain motors
            driveTrain.leftMotor.Stop(brake);
            driveTrain.rightMotor.Stop(brake);
        end
    end
end