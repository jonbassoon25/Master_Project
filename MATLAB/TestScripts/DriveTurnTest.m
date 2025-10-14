brick = ConnectBrick('GROUP6');

driveTrain = DriveTrain(brick, 'A', 'D');

for i = 1:4
    driveTrain.SetForwardVelocity(20); % Set foward velocity to 20cm/s
    updateCount = 20;
    
    for j = 1:updateCount
        driveTrain.ManageVelocityTargets();
    end

    driveTrain.TurnLeft(90);
    %driveTrain.TurnRight(90);
end

motor.Stop('Coast');

clear;