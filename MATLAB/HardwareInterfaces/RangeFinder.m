classdef RangeFinder < handle
    % Controls the RangeFinder of the vehicle

    %TODO: FIX BEARING DEGREES SO THAT THEY ARE CLOCKWISE FOR +rad INSTEAD OF COUNTERCLOCKWISE FOR +rad
    %TODO: RECORD THETA & DISTANCE OF N-2 TO N FOR MIN/MAX RANGES INSTEAD OF N-1 TO N

    properties (Constant, Access = private)
        DEBUG = true
    end

    properties (Constant, Access = protected)
        SCAN_FOV double = 270   % Scan field of view in degrees
        SCAN_SPEED double = 0.08 % Scan speed as a decimal of the motor power
    end

    properties (Access = protected)
        motor Motor
        driveTrain DriveTrain
        ultraSensor UltrasonicSensor
        targetMotorVelocity double

        lastScan RangeScan   % The last complete scan
        nextScan RangeScan   % The scan that is currently being built
        fullScanMode logical % Are we currently doing a full scan

        lastDistance double     % The last recorded distance of the ultrasonic sensor
        lastTheta double        % The last recorded angle of the ultrasonic sensor rotator
        last_dDdT double        % The last recorded change in distance per change in theta
        SCAN_OFFSET double = 0  % Offset of the 0 of the scan motor in degrees
    end

    methods (Access = public)
        function rangeFinder = RangeFinder(motor, driveTrain, ultrasonicSensor)
            arguments (Input)
                motor Motor
                driveTrain DriveTrain
                ultrasonicSensor UltrasonicSensor
            end
            arguments (Output)
                rangeFinder RangeFinder
            end

            rangeFinder.motor = motor;
            rangeFinder.driveTrain = driveTrain;
            rangeFinder.ultraSensor = ultrasonicSensor;
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            
            rangeFinder.motor.UpdateData();
            rangeFinder.SCAN_OFFSET = rangeFinder.motor.GetCurrentAngle();
            rangeFinder.lastDistance = rangeFinder.ultraSensor.GetDistance();
            rangeFinder.lastTheta = rangeFinder.motor.GetCurrentAngle();
            rangeFinder.last_dDdT = 0.0;
        end

        function Start(rangeFinder)
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            rangeFinder.motor.SendOutputPower(rangeFinder.SCAN_SPEED);
        end

        function Stop(rangeFinder)
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            rangeFinder.motor.Stop(0);
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
            while (abs(rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET + rangeFinder.SCAN_FOV / 2) > 12)
                if (rangeFinder.DEBUG)
                    fprintf("Current range finder angle: %.2f degs. Rotating to: %.2f +/- 4 degs\n", rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET, rangeFinder.SCAN_FOV / 2);
                end
                rangeFinder.motor.ManageSetTargets();
            end
            % Set the motor to the correct speed
            rangeFinder.motor.SendOutputPower(rangeFinder.SCAN_SPEED);
            if (rangeFinder.DEBUG)
                fprintf("Setting range finder rotation power to %.2f\n", rangeFinder.SCAN_SPEED);
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
            rangeFinder.motor.Stop(0);
            
            scan = rangeFinder.lastScan();
        end

        function Update(rangeFinder)
            rangeFinder.motor.UpdateData();

            theta = pi/180 * (rangeFinder.motor.GetCurrentAngle() - rangeFinder.SCAN_OFFSET);
            distance = rangeFinder.ultraSensor.GetDistance();
            velocity = [0, rangeFinder.driveTrain.GetForwardVelocity()];

            u = [cos(theta), sin(theta)];
            correctedDistance = distance + dot(velocity, u);
            
            dDistance_dTheta = (correctedDistance - rangeFinder.lastDistance) / (theta - rangeFinder.lastTheta);
            fprintf("Recorded angle: %.2frad\nRecorded distance: %.2fcm\nCorrected distance: %.2fcm\ndDistance_dTheta: %.2fcm/rad\n", theta, distance, correctedDistance, dDistance_dTheta);
            
            if ((dDistance_dTheta == 0) && (rangeFinder.last_dDdT == 0))
                % Cannot determine max or min
                if (rangeFinder.DEBUG)
                    fprintf("An undefined range detected from %.2f rad to %.2f rad\n", rangeFinder.lastTheta, theta);
                end

            elseif ((rangeFinder.last_dDdT <= 0) && (dDistance_dTheta >= 0))
                % There is a minimum distance to the measured surface
                rangeFinder.nextScan.addMinima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
                if (rangeFinder.DEBUG)
                    fprintf("A local minimum was detected between %.2f rad and %.2f rad at (%.2fcm, %.2fcm)\n", rangeFinder.lastTheta, theta, rangeFinder.lastDistance, correctedDistance);
                end
                
            elseif ((rangeFinder.last_dDdT >= 0) && (dDistance_dTheta <= 0))
                % There is a maximum distance to the measured surface
                rangeFinder.nextScan.addMaxima(rangeFinder.lastTheta, rangeFinder.lastDistance, theta, correctedDistance);
                if (rangeFinder.DEBUG)
                    fprintf("A local maximum was detected between %.2f rad and %.2f rad (%.2fcm, %.2fcm)\n", rangeFinder.lastTheta, theta, rangeFinder.lastDistance, correctedDistance);
                end
            end

            rangeFinder.lastDistance = distance;
            rangeFinder.lastTheta = theta;
            rangeFinder.last_dDdT = dDistance_dTheta;

            % Turn motor around and update last scan if it is out of rotation range
            if (180/pi * theta > rangeFinder.SCAN_FOV / 2.0)
                fprintf("Updating last scan. Motor past upper FOV bound.\n");
                rangeFinder.motor.SendOutputPower(-rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
                rangeFinder.fullScanMode = false;
            elseif (180/pi * theta < -rangeFinder.SCAN_FOV / 2.0)
                fprintf("Updating last scan. Motor past lower FOV bound.\n");
                rangeFinder.motor.SendOutputPower(rangeFinder.SCAN_SPEED);
                rangeFinder.lastScan = rangeFinder.nextScan;
                rangeFinder.nextScan = RangeScan();
                rangeFinder.fullScanMode = false;
            end
        end

        function bearing = GetTrueForwardBearing(rangeFinder)
            % TODO: Implement
            bearing = 0.0;
        end
        
        function distance = GetMinDistanceBearing(rangeFinder, degrees, relativeBearing)
            arguments (Input)
                rangeFinder RangeFinder % This rangefinder object
                degrees double          % The bearing in degrees to check
                relativeBearing logical % Is the bearing relative to the car (1) or to the maze (0)
            end
            arguments (Output)
                distance double % The approximate distance to the wall in the specified direction
            end
            % Calculates the true minimum distance to a wall in the
            % specified direction from forwards or NaN if no real distance
            % exists

            % TODO: Implement
        end

        function distance = GetMaxDistanceBearing(rangeFinder, degrees, relativeBearing)
            % Calculates the true maximum distance to a wall in the
            % specified direction from forwards or NaN if no real distance
            % exists
            
            % TODO: Implement
        end
    end
end