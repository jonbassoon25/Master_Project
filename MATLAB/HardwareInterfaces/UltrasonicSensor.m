classdef UltrasonicSensor
    % A hardware interface for an ultrasonic sensor

    properties (Access = protected)
        brick Brick
        port uint8
    end

    methods (Access = public)
        function sensor = UltrasonicSensor(brick, port)
            sensor.brick = brick;
            sensor.port = port;
        end

        function distance = GetDistance(sensor)
            distance = sensor.brick.UltrasonicDist(sensor.port);
        end
    end
end