% Initialize the EV3 brick
brick = ConnectBrick('GROUP6');
reading = brick.TouchPressed(1);

while 1
    brick.playTone(100, 500, 100);
    if brick.TouchPressed(1)
        break; 
    end
end