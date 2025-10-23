brick = ConnectBrick('GROUP6');
driveTrain = DriveTrain(brick, 'A', 'D');
olorSensor = ColorSensor(brick, -1);
touchSensor = TouchSensor(brick, -1);
rotator = Motor(brick, 'B');
arm = Motor(brick, 'C');
ultrasonicSensor = UltrasonicSensor(brick, -1);
autopilot = AutonomousController(driveTrain, rangeFinder, colorSensor, touchSensor);


% TODO : Check if Moving Functions of AUTO PILOT WORK
autopilot.TurnRight();
pause(2);
autopilot.TurnLeft();
pause(2);
autopilot.MoveForward();



% TODO : Check if 


autopilot.Navigate(Colors.Blue);



