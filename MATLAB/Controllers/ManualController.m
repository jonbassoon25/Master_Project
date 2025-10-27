classdef ManualController < handle
    % Controls the provided DriveTrain given keyboard input

    properties (Constant, Access=private)
        DEBUG logical = false % Display debug information at runtime
    end

    properties (Access = protected, Constant)
        FORWARD_ACCELERATION double = 36.0  % The forward acceleration constant in cm/s²
        ANGULAR_ACCELERATION double = 120.0 % The angular acceleration constant in deg/s² counter clockwise
        ARM_ACCELERATION double = 120.0     % The angular acceleration constnt in deg/s² counter clockwise
        MAX_DRIVE_VELOCITY double = 180.0   % The maximum foward velocity magnitude in cm/s
        MAX_TURNING_RATE double = 720.0     % The maximum turning rate magnitude in deg/s
        MAX_ARM_VELOCITY double = 360.0      % The maximum arm angular velocity magnitude in deg/s
    end


    properties (Access = protected)
        keyboard Keyboard            % The Keyboard to detect user input from
        driveTrain DriveTrain        % The DriveTrain to send control output to
        arm Motor                    % The arm connected to the car
        targetForwardVelocity double % The current target forward velocity in cm/s
        targetAngularVelocity double % The current target angular velocity in deg/s counter clockwise
        targetArmVelocity double     % The current target angular velocity of the arm in deg/s counter clockwise
    end


    methods (Access = public)
        function controller = ManualController(keyboard, driveTrain, arm)
            % Initializes the properties of a new ManualController object
            arguments (Input)
                keyboard Keyboard     % The Keyboard to detect user input from
                driveTrain DriveTrain % The DriveTrain to send control output to
                arm Motor             % The Motor controlling the arm of the car
            end
            arguments (Output)
                controller ManualController % The constructed ManualController object
            end
 
            controller.keyboard = keyboard;
            controller.driveTrain = driveTrain;
            controller.arm = arm;
            controller.targetForwardVelocity = 0.0;
            controller.targetAngularVelocity = 0.0;
            controller.targetArmVelocity = 0.0;
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
            armUpInput = controller.keyboard.IsPressed("r");
            armDownInput = controller.keyboard.IsPressed("f");
            
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
            if (armUpInput) % Arm Up Input
                controller.targetArmVelocity = controller.targetArmVelocity - controller.ARM_ACCELERATION;
            end
            if (armDownInput) % Arm Down Input
                controller.targetArmVelocity = controller.targetArmVelocity + controller.ARM_ACCELERATION;
            end

            % No Forward or Backward Input
            if (~(fowardInput || backwardInput)) 
                controller.targetForwardVelocity = 0;
            end 
            % No Left or Right Input
            if (~(leftInput || rightInput))
                controller.targetAngularVelocity = 0;
            end
            % No Arm Up or Down Input
            if (~(armUpInput || armDownInput))
                controller.targetArmVelocity = 0;
            end

            if (controller.DEBUG)
                fprintf("Control Input:\n\tForward: %d\n\tBackward: %d\n\tLeft: %d\n\tRight: %d\n\tUp: %d\n\tDown: %d\n", fowardInput, backwardInput, leftInput, rightInput, armUpInput, armDownInput);
                fprintf("Control Output:\n\tFoward Velocity: %.2f\n\tAngular Velocity: %.2f\n\tArm Velocity: %.2f\n", controller.targetForwardVelocity, controller.targetAngularVelocity, controller.targetArmVelocity);
            end

            % Make sure target forward velocity and target angular velocity
            % are bounded
            if (controller.targetForwardVelocity > controller.MAX_DRIVE_VELOCITY)
                controller.targetForwardVelocity = controller.MAX_DRIVE_VELOCITY;
            elseif (controller.targetForwardVelocity < -controller.MAX_DRIVE_VELOCITY)
                controller.targetForwardVelocity = -controller.MAX_DRIVE_VELOCITY;
            end

            if (controller.targetAngularVelocity > controller.MAX_TURNING_RATE)
                controller.targetAngularVelocity = controller.MAX_TURNING_RATE;
            elseif (controller.targetAngularVelocity < -controller.MAX_TURNING_RATE)
                controller.targetAngularVelocity = -controller.MAX_TURNING_RATE;
            end

            % Make sure target arm velocity is bounded
            if (controller.targetArmVelocity > controller.MAX_ARM_VELOCITY)
                controller.targetArmVelocity = controller.MAX_ARM_VELOCITY;
            elseif (controller.targetArmVelocity < -controller.MAX_ARM_VELOCITY)
                controller.targetArmVelocity = -controller.MAX_ARM_VELOCITY;
            end
   
            % Set & Manage DriveTrain Movement Targets
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();

            controller.arm.SetVelocityTarget(controller.targetArmVelocity);
            controller.arm.ManageSetTargets();
        end
    end
end