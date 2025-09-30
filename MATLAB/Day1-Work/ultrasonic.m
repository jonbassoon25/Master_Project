brick = ConnectBrick('PHIL');

while (true)
    distance = brick.UltrasonicDist(2);
    fprintf("%d cm\n", distance);

    if (distance < 25)
        brick.playTone(100, 500, 100);
    end
end