classdef Motor < handle
    % A motor connected to a brick

    properties (Access = protected)
        % Hardware values
        brick
        port

        % Current motor data
        currentAngle
        currentVelocity
        currentAcceleration
        measurementClock
    end

    methods (Access = public)
        function motor = Motor(brick, port)
            % Constructs a new motor object.

            % Set hardware values
            motor.port = port;
            motor.brick = brick;

            % Set initial motor data values
            motor.currentAngle = 0;
            motor.currentVelocity = 0;
            motor.currentAcceleration = 0;

            motor.measurementClock = tic;
        end

        function UpdateData(motor)
            % Updates the current motor data
            deltaTime = toc(motor.measurementClock);
            motor.measurementClock = tic;

            newAngle = motor.brick.GetMotorAngle(motor.port);
            newVelocity = (newAngle - motor.currentAngle) / deltaTime;
            newAcceleration = (newVelocity - motor.currentVelocity) / deltaTime;

            motor.currentAngle = newAngle;
            motor.currentVelocity = newVelocity;
            motor.currentAcceleration = newAcceleration;
        end


        % Getter Methods
        function angle = GetCurrentAngle(motor)
            angle = motor.currentAngle;
        end

        function angularVelocity = GetCurrentVelocity(motor)
            angularVelocity = motor.currentVelocity;
        end

        function angularAcceleration = GetCurrentAcceleration(motor)
            angularAcceleration = motor.currentAcceleration;
        end
    end
end