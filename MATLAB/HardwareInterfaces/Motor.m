classdef Motor < handle
    % A Motor object represents a motor connected to an EV3 brick

    properties (Constant, Access = protected)
        ANGLE_PID PID = PID(0.005, 255, 5);           % The angle PID controller for this motor
        VELOCITY_PID PID = PID(0.00031, 80, 0.01325); % The velocity PID controller for this motor
    end

    properties (Access = protected)
        brick Brick                % The EV3 brick that this motor is connected to
        port string                % The motor port letter that this motor is connected to
        currentAngle double        % The current angle of this motor in degrees
        currentVelocity double     % The current velocity of this motor in deg/sec
        currentAcceleration double % The current acceleration of this motor in deg/sec²
        measurementClock           % The clock recording the time since the last update cycle
        movementMode uint8         % The current movement mode of this motor. 0 for none, 1 for angle, 2 for velocity
        angleTarget double         % The target angle of this motor in degrees
        velocityTarget double      % The target velocity of this motor 
    end

    methods (Access = public)
        function motor = Motor(brick, port)
            % Initializes the properties of a new Motor object
            arguments (Input)
                brick Brick % The EV3 brick that this motor is connected to
                port string % The motor port letter that this motor is connected to
            end
            arguments (Output)
                motor Motor % The constructed Motor object
            end

            % Set hardware values
            motor.port = port;
            motor.brick = brick;

            % Set initial motor data values
            motor.currentAngle = 0;
            motor.currentVelocity = 0;
            motor.currentAcceleration = 0;
            motor.measurementClock = tic;
            
            % Populate the data values
            for i = 0:2
                motor.UpdateData();
            end

            % Set the initial targets & movement mode
            motor.angleTarget = 0.0;
            motor.velocityTarget = 0.0;
            motor.movementMode = 0;
        end

        function UpdateData(motor)
            % Updates the current motor data & active PID
            arguments (Input)
                motor Motor % This Motor object
            end
            deltaTime = toc(motor.measurementClock);
            fprintf("Last control loop took %.2f seconds\n", deltaTime);
            motor.measurementClock = tic;

            newAngle = motor.brick.GetMotorAngle(motor.port);
            newVelocity = (newAngle - motor.currentAngle) / deltaTime;
            newAcceleration = (newVelocity - motor.currentVelocity) / deltaTime;

            motor.currentAngle = newAngle;
            motor.currentVelocity = newVelocity;
            motor.currentAcceleration = newAcceleration;

            fprintf("Current Angle: %.2f\n", newAngle);
            fprintf("Current Velocity: %.2f\n", newVelocity);
            fprintf("Current Acceleration: %.2f\n", newAcceleration);

            if (motor.movementMode == 1)
                % Update the angle PID
                motor.ANGLE_PID.updateErrorState(motor.currentAngle - motor.angleTarget, deltaTime);

            elseif (motor.movementMode == 2)
                % Update the velocity PID
                motor.VELOCITY_PID.updateErrorState(motor.currentVelocity - motor.velocityTarget, deltaTime);
            end
        end

        function ManageSetTargets(motor)
            % Manages the currently set targets so that they are met
            arguments (Input)
                motor Motor % This Motor object
            end

            % Get the current motor data values
            motor.UpdateData();

            if (motor.movementMode == 1)
                % Manage the motor angle
                controlOutput = -motor.ANGLE_PID.calculateControlOutput();
                
            elseif (motor.movementMode == 2)
                % Manage the motor velocity 
                controlOutput = -motor.VELOCITY_PID.calculateControlOutput();
                
            else
                controlOutput = 0;
            end

            motor.brick.MoveMotor(motor.port, controlOutput * 100);
        end

        function Stop(motor, brake)
            % Stops this motor
            arguments (Input)
                motor Motor % This Motor object
                brake string = "coast" % Should the motor break to stop
            end
            motor.ClearTargets();
            motor.brick.StopMotor(motor.port, brake);
        end

        
        function ClearTargets(motor)
            % Clears this motor's set targets
            arguments (Input)
                motor Motor % This Motor object
            end
            motor.angleTarget = [];
            motor.velocityTarget = [];
            motor.movementMode = 0;
            motor.ANGLE_PID.reset();
            motor.VELOCITY_PID.reset();
        end

        function SetAngleTarget(motor, target)
            % Sets the absolute target angle of this motor
            arguments (Input)
                motor Motor   % This Motor object
                target double % The absolute target angle in degrees
            end
            motor.ClearTargets();
            motor.UpdateData();
            motor.angleTarget = target + fix(motor.currentAngle / 360) * 360;
            motor.movementMode = 1;
        end

        function SetRelAngleTarget(motor, relTarget)
            % Sets the relative target angle of this motor
            arguments (Input)
                motor Motor   % This Motor object
                relTarget double % The relative target angle in degrees
            end
            motor.ClearTargets();
            motor.UpdateData();
            motor.angleTarget = relTarget + motor.currentAngle;
            motor.movementMode = 1;
        end

        function SetVelocityTarget(motor, target)
            % Sets the target velocity of this motor
            arguments (Input)
                motor Motor   % This Motor object
                target double % The relative target velocity in deg/s
            end
            motor.ClearTargets();
            motor.velocityTarget = target;
            motor.movementMode = 2;
        end

        function angle = GetCurrentAngle(motor)
            % Gets the last measured angle of the motor
            arguments (Input)
                motor Motor % This Motor object
            end
            arguments (Output)
                angle double % The last measured angle of the motor in degrees
            end
            angle = motor.currentAngle;
        end

        function angleTarget = GetCurrentAngleTarget(motor)
            % Gets the target angle of the motor
            arguments (Input)
                motor Motor % This Motor object
            end
            arguments (Output)
                angleTarget double % The target angle of the motor in degrees
            end
            angleTarget = motor.angleTarget;
        end

        function angularVelocity = GetCurrentVelocity(motor)
            % Gets the last measured angular velocity of the motor
            arguments (Input)
                motor Motor % This Motor object
            end
            arguments (Output)
                angularVelocity double % The last measured velocity of the motor in deg/s
            end
            angularVelocity = motor.currentVelocity;
        end

        function angularVelocityTarget = GetCurrentVelocityTarget(motor)
            % Gets the target velocity of the motor
            arguments (Input)
                motor Motor % This Motor object
            end
            arguments (Output)
                angularVelocityTarget double % The target angular velocity of the motor in deg/s
            end
            angularVelocityTarget = motor.velocityTarget;
        end

        function angularAcceleration = GetCurrentAcceleration(motor)
            % Gets the last measured angular acceleration of the motor
            arguments (Input)
                motor Motor % This Motor object
            end
            arguments (Output)
                angularAcceleration double % The last measured acceleration of the motor in deg/s²
            end
            angularAcceleration = motor.currentAcceleration;
        end
    end
end