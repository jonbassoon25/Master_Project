classdef ManualController < handle
    % A manual controller class for the car

    properties (Access = protected)
        keyboard
        driveTrain
        forwardAcceleration
        angularAcceleration
        targetForwardVelocity
        targetAngularVelocity
    end


    methods (Access = public)
        function controller = ManualController(keyboard, driveTrain)
            % Static values
            controller.forwardAcceleration = 1; % Must be > 0. find actual value
            controller.angularAcceleration = 1; % Must be > 0. find actual value

            % Initialize values
            controller.keyboard = keyboard;
            controller.driveTrain = driveTrain;
            controller.targetForwardVelocity = 0.0;
            controller.targetAngularVelocity = 0.0; % Counter clockwise
        end

        function Reset(controller)
            controller.targetForwardVelocity = 0.0;
            controller.targetAngularVelocity = 0.0;
            controller.driveTrain.Stop();
        end

        function Update(controller)
            % Updates the car's motion based on the keyboard input
            if (isPressed("w"))
                controller.targetForwardVelocity = controller.targetForwardVelocity + controller.forwardAcceleration;
            elseif (isPressed("s"))
                controller.targetForwardVelocity = controller.targetForwardVelocity - controller.forwardAcceleration;
            else
                if (controller.targetForwardVelocity < 0)
                    controller.targetForwardVelocity = controller.targetForwardVelocity + controller.forwardAcceleration;
                    if (controller.targetForwardVelocity > 0)
                        controller.targetForwardVelocity = 0;
                    end
                else
                    controller.targetForwardVelocity = controller.targetForwardVelocity - controller.forwardAcceleration;
                    if (controller.targetForwardVelocity < 0)
                        controller.targetForwardVelocity = 0;
                    end
                end
            end

            if (isPressed("a"))
                controller.targetAngularVelocity = controller.targetAngularVelocity + controller.angularAcceleration;
            elseif (isPressed("d"))
                controller.targetAngularVelocity = controller.targetAngularVelocity - controller.angularAcceleration;
            else
                if (controller.targetAngularVelocity < 0)
                    controller.targetAngularVelocity = controller.targetAngularVelocity + controller.angularAcceleration;
                    if (controller.targetAngularVelocity > 0)
                        controller.targetAngularVelocity = 0;
                    end
                else
                    controller.targetAngularVelocity = controller.targetAngularVelocity - controller.angularAcceleration;
                    if (controller.targetAngularVelocity < 0)
                        controller.targetAngularVelocity = 0;
                    end
                end
            end
                
            controller.driveTrain.SetMixedMovementTargets(controller.targetForwardVelocity, controller.targetAngularVelocity);
            controller.driveTrain.ManageVelocityTargets();
        end
    end
end