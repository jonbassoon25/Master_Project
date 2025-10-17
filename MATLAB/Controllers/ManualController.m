classdef ManualController < handle
    % Controls the provided DriveTrain given keyboard input

    properties (Constant, Access=private)
        DEBUG logical = true % Display debug information at runtime
    end

    properties (Access = protected, Constant)
        FORWARD_ACCELERATION double = 36.0 % The forward acceleration constant in cm/s²
        ANGULAR_ACCELERATION double = 120.0 % The angular acceleration constant in deg/s² counter clockwise
        MAX_MOTOR_VELOCITY double = 180    % The maximum foward velocity magnitude in cm/s
        MAX_TURNING_RATE double = 720    % The maximum turning rate magnitude in deg/s
    end


    properties (Access = protected)
        keyboard Keyboard            % The Keyboard to detect user input from
        driveTrain DriveTrain        % The DriveTrain to send control output to
        targetForwardVelocity double % The current target forward velocity in cm/s
        targetAngularVelocity double % The current target angular velocity in deg/s counter clockwise
    end


    methods (Access = public)
        function controller = ManualController(keyboard, driveTrain)
            % Initializes the properties of a new ManualController object
            arguments (Input)
                keyboard Keyboard     % The Keyboard to detect user input from
                driveTrain DriveTrain % The DriveTrain to send control output to
            end
            arguments (Output)
                controller ManualController % The constructed ManualController object
            end
 
            controller.keyboard = keyboard;
            controller.driveTrain = driveTrain;
            controller.targetForwardVelocity = 0.0;
            controller.targetAngularVelocity = 0.0;
        end

        function Reset(controller)
            % Resets the control output variables & stops the controlled DriveTrain
            arguments
                controller ManualController % This ManualController Object
            end

            controller.targetForwardVelocity = 0.0;
            controller.targetAngularVelocity = 0.0;
            controller.driveTrain.Stop();
        end
       
        function Update(controller)
            % Updates the control output to the DriveTrain based on keyboard input
            arguments
                controller ManualController % This ManualController Object
            end

            fowardInput = controller.keyboard.IsPressed("w");
            backwardInput = controller.keyboard.IsPressed("s");
            leftInput = controller.keyboard.IsPressed("a");
            rightInput = controller.keyboard.IsPressed("d");
            
            if (fowardInput) % Forward Input
                controller.targetForwardVelocity = controller.targetForwardVelocity + controller.FORWARD_ACCELERATION;
            end
            if (backwardInput) % Backward Input
                controller.targetForwardVelocity = controller.targetForwardVelocity - controller.FORWARD_ACCELERATION;
            end
            if (leftInput) % Left Input
                controller.targetAngularVelocity = controller.targetAngularVelocity + controller.ANGULAR_ACCELERATION;
            end
            if (rightInput) % Right Input
                controller.targetAngularVelocity = controller.targetAngularVelocity - controller.ANGULAR_ACCELERATION;
            end

            % No Forward or Backward Input
            if (~(fowardInput || backwardInput)) 
                controller.targetForwardVelocity = 0;
            end 
            % No Left or Right Input
            if (~(leftInput || rightInput))
                controller.targetAngularVelocity = 0;
            end

            if (controller.DEBUG)
                fprintf("Control Input:\n\tForward: %d\n\tBackward: %d\n\tLeft: %d\n\tRight: %d\n", fowardInput, backwardInput, leftInput, rightInput);
                fprintf("Control Output:\n\tFoward Velocity: %.2f\n\tAngular Velocity: %.2f\n", controller.targetForwardVelocity, controller.targetAngularVelocity);
            end

            % Make sure target forward velocity and target angular velocity
            % are bounded
            if (controller.targetForwardVelocity > controller.MAX_MOTOR_VELOCITY)
                controller.targetForwardVelocity = controller.MAX_MOTOR_VELOCITY;
            elseif (controller.targetForwardVelocity < -controller.MAX_MOTOR_VELOCITY)
                controller.targetForwardVelocity = -controller.MAX_MOTOR_VELOCITY;
            end

            if (controller.targetAngularVelocity > controller.MAX_TURNING_RATE)
                controller.targetAngularVelocity = controller.MAX_TURNING_RATE;
            elseif (controller.targetAngularVelocity < -controller.MAX_TURNING_RATE)
                controller.targetAngularVelocity = -controller.MAX_TURNING_RATE;
            end
   
            % Set & Manage DriveTrain Movement Targets
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
        end
    end
end