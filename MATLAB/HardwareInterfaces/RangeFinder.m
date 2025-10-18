classdef RangeFinder < handle
    % Controls the RangeFinder of the vehicle

    properties (Access = protected)
        motor Motor
        ultraSensor UltrasonicSensor
        targetMotorVelocity double

        lastScan RangeScan % The last complete scan
        nextScan RangeScan % The scan that is currently being built
    end

    methods (Access = public)
        function rangeFinder = RangeFinder(motor, ultrasonicSensor)
            arguments (Input)
                motor Motor
                ultrasonicSensor UltrasonicSensor
            end
            arguments (Output)
                rangeFinder RangeFinder
            end

            rangeFinder.motor = motor;
            rangeFinder.ultraSensor = ultrasonicSensor;
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
        end
    end
end