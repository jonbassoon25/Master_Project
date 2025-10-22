brick = ConnectBrick('GROUP6');

rotator = Motor(brick, 'B');
ultrasonicSensor = UltrasonicSensor(brick, 3);
rangeFinder = RangeFinder(rotator, ultrasonicSensor);

rangeFinder.CompleteFullScan();

%for i = 0:120
%    rangeFinder.Update();
%end

clear;