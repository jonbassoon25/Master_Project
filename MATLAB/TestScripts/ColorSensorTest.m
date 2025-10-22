brick = ConnectBrick('GROUP6');

keyboard = Keyboard();
colorSensor = ColorSensor(brick, -1);

while (~keyboard.IsPressed('q'))
    disp(colorSensor.GetColor());
end

clear;