brick = ConnectBrick('GROUP6');

rotator = Motor(brick, 'B');
ultrasonicSensor = UltrasonicSensor(brick, -1);
rangeFinder = RangeFinder(rotator, ultrasonicSensor);

rangeFinder.CompleteFullScan();

%for i = 0:120
%    rangeFinder.Update();
%end

clear;