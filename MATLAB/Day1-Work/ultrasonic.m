brick = ConnectBrick('GROUP6');

while (true)
    distance = brick.UltrasonicDist(2);
    fprintf("%d cm\n", distance);
end