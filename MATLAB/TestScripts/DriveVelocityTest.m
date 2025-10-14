brick = ConnectBrick('GROUP6');

driveTrain = DriveTrain(brick, 'A', 'D');

driveTrain.SetForwardVelocity(20); % Set foward velocity to 20cm/s
updateCount = 120;

for i = 1:updateCount
    driveTrain.ManageVelocityTargets();
end

motor.Stop('Coast');

clear;