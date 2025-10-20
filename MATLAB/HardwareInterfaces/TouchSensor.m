classdef TouchSensor
    % A hardware interface for a touch sensor

    properties
        brick Brick
        port uint8
    end

    methods
        function sensor = TouchSensor(brick, port)
            sensor.brick = brick;
            sensor.port = port;
        end

        function pressed = IsPressed(sensor)
            pressed = sensor.brick.TouchPressed(sensor.port);
        end
        
        function bumped = IsBumped(sensor)
            bumped = sensor.brick.TouchBumped(sensor.port);
        end
    end
end