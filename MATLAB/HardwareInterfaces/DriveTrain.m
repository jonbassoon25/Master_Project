classdef DriveTrain < handle
    % The drivetrain of the vehicle
    %   This controlls the two motors on the vechicle to
    %   perform complex manuvers

    properties (Access = protected)
        % Hardware variable references
        brick
        leftMotor
        rightMotor
    end


    methods (Access = public)
        function driveTrain = driveTrain(brick, leftMotorPort, rightMotorPort)
            %Construct an instance of this class

            % Set hardware variables
            driveTrain.brick = brick;
            driveTrain.leftMotor = Motor(brick, leftMotorPort);
            driveTrain.rightMotor = Motor(brick, rightMotorPort);
        end
    end
end