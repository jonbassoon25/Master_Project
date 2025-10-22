brick = ConnectBrick('GROUP6');

rotator = Motor(brick, 'B');
driveTrain = DriveTrain(brick, 'A', 'D');
ultrasonicSensor = UltrasonicSensor(brick, 3);
rangeFinder = RangeFinder(rotator, driveTrain, ultrasonicSensor);

%rangeFinder.CompleteFullScan();

rangeFinder.Start();
for i = 0:240
    rangeFinder.Update();
end
rangeFinder.Stop();

clear;