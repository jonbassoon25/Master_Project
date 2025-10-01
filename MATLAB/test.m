brick = ConnectBrick('GROUP6');

motor = Motor(brick, 'A');

motor.SetVelocityTarget(720 * 4); % Set velocity target to 720 degrees per second
updateCount = 120;
for i = 1:updateCount
    motor.ManageSetTargets();
end

motor.Stop('Coast');

%motor.SetAngleTarget(0); % Set angle target to 0 degrees
%for i = 1:updateCount
%    motor.UpdateData();
%    motor.ManageSetTargets();
%end

%motor.Stop('Coast');

clear;