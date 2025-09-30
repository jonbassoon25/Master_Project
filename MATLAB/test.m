brick = ConnectBrick('PHIL');

motor = Motor(brick, 'A');

motor.SetVelocityTarget(720); % Set velocity target to 720 degrees per second
while (true)
    motor.UpdateData();
    motor.ManageSetTargets();
end

motor.SetAngleTarget(0); % Set angle target to 0 degrees
while (true)
    motor.UpdateData();
    motor.ManageSetTargets();
end