brick = ConnectBrick('GROUP6');

brick.SetColorMode(3, 2);

while true
  color = brick.ColorCode(3);

  switch color
      case 0
          disp("No color");
      case 1
          disp("Black");
      case 2
          disp("Blue");
      case 3
          disp("Green");
      case 4
          disp("Yellow");
      case 5
          disp("Red");
      case 6
          disp("White");
      case 7
          disp("Brown");
  end
end
