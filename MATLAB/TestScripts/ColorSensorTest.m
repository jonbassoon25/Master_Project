brick = ConnectBrick('GROUP6');

keyboard = Keyboard();
colorSensor = ColorSensor(brick, 4);

while (~keyboard.IsPressed('q'))
    disp(colorSensor.GetColor());
end

clear;