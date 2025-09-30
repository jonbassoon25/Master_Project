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

        % Current Movement Mode
        %   0 for none, 1 for angle, 2 for velocity
        movementMode

        % Movement Targets
        angleTarget
        velocityTarget

        % Movement PIDs
        anglePID
        velocityPID
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

            motor.UpdateData();

            % Set initial targets & movement mode
            motor.angleTarget = null;
            motor.velocityTarget = null;
            motor.movementMode = 0;

            % Initialize PID controller variables
            motor.anglePID = PID(0.05, 255, 5);
            motor.velocityPID = PID(0.05, 255, 0);
        end

        function UpdateData(motor)
            % Updates the current motor data & active PID
            deltaTime = toc(motor.measurementClock);
            motor.measurementClock = tic;

            newAngle = motor.brick.GetMotorAngle(motor.port);
            newVelocity = (newAngle - motor.currentAngle) / deltaTime;
            newAcceleration = (newVelocity - motor.currentVelocity) / deltaTime;

            motor.currentAngle = newAngle;
            motor.currentVelocity = newVelocity;
            motor.currentAcceleration = newAcceleration;

            if (motor.movementMode == 1)
                % Update the angle PID
                motor.anglePID.updateErrorState()

            elseif (motor.movementMode == 2)
                % Update the velocity PID
                
            end
        end

        function ManageSetTargets(motor)
            % Manages the currently set targets so that they are met
            %   Will ignore the angle target if the angle target is null
            %   and the velocity target is null

            % Get the current motor data values
            motor.UpdateData();

            if (motor.movementMode == 1)
                % Manage the motor angle
                
            elseif (motor.movementMode == 2)
                % Manage the motor velocity 
                
            end
        end

        
        % Target Management Methods
        function ClearTargets(motor)
            motor.angleTarget = null;
            motor.velocityTarget = null;
            motor.movementMode = 0;
            motor.anglePID.reset();
            motor.velocityPID.reset();
        end

        function SetAngleTarget(motor, target)
            motor.ClearTargets();
            motor.angleTarget = target;
            motor.movementMode = 1;
        end

        function SetVelocityTarget(motor, target)
            motor.ClearTargets();
            motor.velocityTarget = target;
            motor.movementMode = 2;
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