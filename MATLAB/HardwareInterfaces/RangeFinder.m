classdef RangeFinder < handle
    % Controls the RangeFinder of the vehicle

    properties (Constant, Access = private)
        DEBUG = true
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

        lastScan RangeScan % The last complete scan
        nextScan RangeScan % The scan that is currently being built
        fullScanMode logical % Are we currently doing a full scan

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
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            
            rangeFinder.motor.UpdateData();
            rangeFinder.lastDistance = rangeFinder.ultraSensor.GetDistance();
            rangeFinder.lastTheta = rangeFinder.motor.GetCurrentAngle();
            rangeFinder.last_dDdT = 0.0;
        end

        function scan = CompleteFullScan(rangeFinder)
            rangeFinder.nextScan = RangeScan();
            rangeFinder.lastScan = RangeScan();
            rangeFinder.fullScanMode = true;
            
            if (rangeFinder.DEBUG)
                fprintf("Clearing rangefinder data & performing a full scan...\n");
            end
            
            % Rotate the scan motor to the correct position
            rangeFinder.motor.SetAngleTarget(-rangeFinder.SCAN_FOV / 2);
            while (abs(rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET + rangeFinder.SCAN_FOV / 2) > 4)
                if (rangeFinder.DEBUG)
                    fprintf("Current range finder angle: %.2f degs. Rotating to: %.2f +/- 4 degs\n", rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET, rangeFinder.SCAN_FOV / 2);
                end
                rangeFinder.motor.ManageSetTargets();
            end
            % Set the motor to the correct speed
            rangeFinder.motor.SetVelocityTarget(rangeFinder.SCAN_SPEED);
            if (rangeFinder.DEBUG)
                fprintf("Setting range finder velocity target to %.2f deg/s\n", rangeFinder.SCAN_SPEED);
            end
            samples = 0;
            while (rangeFinder.fullScanMode)
                rangeFinder.Update();
                samples = samples + 1;
            end
            if (rangeFinder.DEBUG)
                fprintf("Took %d samples before a new full scan was completed.\n", samples);
                fprintf("Scan complete.\n");
            end
            
            scan = rangeFinder.lastScan();
        end

        function Update(rangeFinder)
            rangeFinder.motor.ManageSetTargets();

            theta = pi/180 * (rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET);
            distance = rangeFinder.ultraSensor.GetDistance();
            velocity = [0, rangeFinder.motor.GetCurrentVelocity()];

            u = [cos(theta), sin(theta)];
            correctedDistance = distance + (dot(velocity, u) * u);
            
            dDistance_dTheta = (correctedDistance - rangeFinder.lastDistance) / (theta - rangeFinder.lastTheta);
            
            if (dDistance_dTheta == 0 && rangeFinder.last_dDdT == 0)
                % Cannot determine max or min
                if (rangeFinder.DEBUG)
                    fprintf("An undefined range detected from %.2f rad to %.2f rad\n", rangeFinder.lastTheta, theta);
                end

            elseif (dDistance_dTheta <= 0 && rangeFinder.last_dDdT >= 0)
                % There is a minimum distance to the measured surface
                rangeFinder.nextScan.addMinima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
                if (rangeFinder.DEBUG)
                    fprintf("A local minimum was detected between %.2f rad and %.2f rad at ~%.2fcm\n", rangeFinder.lastTheta, theta, (correctedDistance + rangeFinder.lastDistance) / 2.0);
                end
                
            elseif (dDistance_dTheta >= 0 && rangeFinder.last_dDdT <= 0)
                % There is a maximum distance to the measured surface
                rangeFinder.nextScan.addMaxima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
                if (rangeFinder.DEBUG)
                    fprintf("A local maximum was detected between %.2f rad and %.2f rad at ~%.2fcm\n", rangeFinder.lastTheta, theta, (correctedDistance + rangeFinder.lastDistance) / 2.0);
                end
            end

            rangeFinder.lastDistance = distance;
            rangeFinder.lastTheta = theta;
            rangeFinder.last_dDdT = dDistance_dTheta;

            % Turn motor around and update last scan if it is out of rotation range
            if (abs(theta) > rangeFinder.SCAN_FOV / 2.0)
                fprintf("Updating last scan. Motor past upper FOV bound.\n");
                rangeFinder.motor.SetVelocityTarget(-rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
                rangeFinder.fullScanMode = false;
            elseif (abs(theta) < rangeFinder.SCAN_FOV / 2.0)
                fprintf("Updating last scan. Motor past lower FOV bound.\n");
                rangeFinder.motor.SetVelocityTarget(rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
                rangeFinder.fullScanMode = false;
            end
        end
    end
end