brick = ConnectBrick('GROUP6');

driveTrain = DriveTrain(brick, 'A', 'D');

for i = 1:1
    %driveTrain.SetForwardVelocity(20); % Set forward velocity to 20cm/s
    %updateCount = 20;
    
    %for j = 1:updateCount
    %    driveTrain.ManageVelocityTargets();
    %end

    driveTrain.TurnLeft(90);
    %driveTrain.TurnRight(90);
end

driveTrain.Stop('Coast');

clear;