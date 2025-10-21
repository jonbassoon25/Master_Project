classdef RangeFinder < handle
    % Controls the RangeFinder of the vehicle

    properties (Constant, Access = private)
        DEBUG = false
    end

    properties (Constant, Access = protected)
        SCAN_FOV double = 270   % Scan field of view in degrees
        SCAN_OFFSET double = 0  % Offset of the 0 of the scan motor in degrees
        SCAN_SPEED double = 120 % Scan speed in deg/s
    end

    properties (Access = protected)
        motor Motor
        ultraSensor UltrasonicSensor
        targetMotorVelocity double

        lastScan % The last complete scan or []
        nextScan RangeScan % The scan that is currently being built

        lastDistance double % The last recorded distance of the ultrasonic sensor
        lastTheta double % The last recorded angle of the ultrasonic sensor rotator
        last_dDdT double % The last recorded change in distance per change in theta
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
            
            rangeFinder.motor.UpdateData();
            rangeFinder.lastDistance = rangeFinder.ultraSensor.GetDistance();
            rangeFinder.lastTheta = rangeFinder.motor.GetCurrentAngle();
            rangeFinder.last_dDdT = 0.0;

            rangeFinder.lastScan = rangeFinder.CompleteFullScan();
            rangeFinder.nextScan = RangeScan();
        end

        function scan = CompleteFullScan(rangeFinder)
            rangeFinder.nextScan = RangeScan();
            rangeFinder.lastScan = [];

            fprintf("Performing full scan...\n");
            rangeFinder.motor.SetAngleTarget(-rangeFinder.SCAN_FOV);
            rangeFinder.motor.SetVelocityTarget(rangeFinder.SCAN_SPEED);
            while (isempty(rangeFinder.lastScan))
                rangeFinder.Update();
            end
            fprintf("Scan complete.\n");

            rangeFinder.motor.Stop(0);
            
            scan = rangeFinder.lastScan();
        end

        function Update(rangeFinder)
            rangeFinder.motor.UpdateData();

            theta = rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET;
            distance = rangeFinder.ultraSensor.GetDistance();
            velocity = [0, rangeFinder.motor.GetCurrentVelocity()];

            u = [cos(theta), sin(theta)];
            correctedDistance = distance + (dot(velocity, u));
            
            dDistance_dTheta = (correctedDistance - rangeFinder.lastDistance) / (theta - rangeFinder.lastTheta);
            
            if ((dDistance_dTheta == 0.0) && (rangeFinder.last_dDdT == 0.0))
                % Cannot determine max or min

            elseif ((dDistance_dTheta <= 0) && (rangeFinder.last_dDdT >= 0))
                % There is a minimum distance to the measured surface
                rangeFinder.nextScan.addMinima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
                
            elseif ((dDistance_dTheta >= 0) && (rangeFinder.last_dDdT <= 0))
                % There is a maximum distance to the measured surface
                rangeFinder.nextScan.addMaxima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
            end

            rangeFinder.lastDistance = distance;
            rangeFinder.lastTheta = theta;
            rangeFinder.last_dDdT = dDistance_dTheta;

            % Turn motor around and update last scan if it is out of rotation range
            if (abs(theta) > rangeFinder.SCAN_FOV / 2.0)
                rangeFinder.motor.SetVelocityTarget(-rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
            elseif (abs(theta) < rangeFinder.SCAN_FOV / 2.0)
                rangeFinder.motor.SetVelocityTarget(rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
            end
            rangeFinder.motor.ManageSetTargets();
        end
    end
end