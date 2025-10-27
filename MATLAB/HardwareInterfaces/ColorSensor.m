classdef ColorSensor
    % A hardware interface for an active color sensor

    properties (Access = protected)
        brick Brick % The EV3 brick that this sensor is connected to
        port uint8  % The EV3 port that his sensor is connected to
    end

    methods
        function sensor = ColorSensor(brick, port)
            % Initializes the properties of a new ColorSensor object
            arguments (Input) 
                brick Brick % The EV3 brick that this color sensor is attached to
                port uint8  % The port number that this sensor is attached to
            end
            arguments (Output)
                sensor ColorSensor % The constructed ColorSensor object
            end
            sensor.brick = brick;
            sensor.port = port;

            % Initialize brick color sensor function
            sensor.brick.SetColorMode(sensor.port, 2);
        end

        function color = GetColor(sensor)
            % Retrives the color that the sensor is currently seeing
            arguments (Output)
                color Colors % The color enumeration value of the sensed color
            end
            colorCode = sensor.brick.ColorCode(sensor.port);
            switch colorCode
              case uint8(Colors.Undefined)
                  color = Colors.Undefined;
              case uint8(Colors.Black)
                  color = Colors.Black;
                case uint8(Colors.Blue)
                  color = Colors.Blue;
              case uint8(Colors.Green)
                  color = Colors.Green;
              case uint8(Colors.Yellow)
                  color = Colors.Yellow;
              case uint8(Colors.Red)
                  color = Colors.Red;
                case uint8(Colors.White)
                  color = Colors.White;
              case uint8(Colors.Brown)
                  color = Colors.Brown;
            end
        end
    end
end