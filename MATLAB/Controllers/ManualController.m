classdef ManualController < handle
    % Controls the provided DriveTrain given keyboard input
    properties (Access = protected, Constant)
        FORWARD_ACCELERATION double = 1.0; % The forward acceleration constant in cm/s²
        ANGULAR_ACCELERATION double = 1.0; % The angular acceleration constant in deg/s² counter clockwise
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

            fowardInput = isPressed("w");
            backwardInput = isPressed("s");
            leftInput = isPressed("a");
            rightInput = isPressed("d");
            
            
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
   
            % Set & Manage DriveTrain Movement Targets
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
        end
    end
end