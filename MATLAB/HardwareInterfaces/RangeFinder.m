classdef RangeFinder < handle
    % Controls the RangeFinder of the vehicle

    %TODO: FIX BEARING DEGREES SO THAT THEY ARE CLOCKWISE FOR +rad INSTEAD OF COUNTERCLOCKWISE FOR +rad
    %TODO: RECORD THETA & DISTANCE OF N-2 TO N FOR MIN/MAX RANGES INSTEAD OF N-1 TO N

    properties (Constant, Access = private)
        DEBUG = true
    end

    properties (Constant, Access = protected)
        SCAN_FOV double = 270    % Scan field of view in degrees
        SCAN_SPEED double = 0.08 % Scan speed as a decimal of the motor power
    end

    properties (Access = protected)
        motor Motor
        driveTrain DriveTrain
        ultraSensor UltrasonicSensor
        targetMotorVelocity double

        lastScan RangeScan      % The last complete scan
        nextScan RangeScan      % The scan that is currently being built
        fullScanMode logical    % Are we currently doing a full scan

        lastDistance double     % The last recorded distance of the ultrasonic sensor
        lastTheta double        % The last recorded angle of the ultrasonic sensor rotator
        last_dDdT double        % The last recorded change in distance per change in theta
        SCAN_OFFSET double      % Offset of the 0 of the scan motor in degrees
    end

    methods (Access = public)
        function rangeFinder = RangeFinder(motor, driveTrain, ultrasonicSensor)
            % Constructs a new RangeFinder object
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
            % Starts the RangeFinder. Stop must be called to stop it
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            rangeFinder.motor.SendOutputPower(rangeFinder.SCAN_SPEED);
        end

        function Stop(rangeFinder)
            % Stops the RangeFinder
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            rangeFinder.lastScan = RangeScan();
            rangeFinder.nextScan = RangeScan();
            rangeFinder.motor.Stop(0);
        end

        function scan = CompleteFullScan(rangeFinder)
            % Generates a new last scan. Does not return control until this
            % is complete
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            arguments (Output)
                scan RangeScan % The new generated scan
            end
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
            % Updates the RangeFinder. Start must be called before update
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
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
            % Calculates the true forward bearing of the car based on the
            % last complete scan
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            arguments (Output)
                bearing double % The true forward bearing relative to the current forward bearing
            end
            % Determine the min distance to the wall left & right
            i = 0;
            leftBearing = NaN;
            rightBearing = NaN;
            while (i < rangeFinder.lastScan.minima.length)
                extremaPoint = rangeFinder.lastScan.minima.Get(i);
                approxBearing = 90 - rad2deg((extremaPoint.theta1 + extremaPoint.theta2) / 2.0);
                % Determine min left bearing
                if (approxBearing < 0) 
                    if (isnan(leftBearing) || (approxBearing.distance1 + approxBearing.distance2) / 2.0 < (leftBearing.distance1 + leftBearing.distance2) / 2.0)
                        leftBearing = approxBearing;
                    end
                % Determine min right bearing
                elseif (approxBearing > 0)
                    if (isnan(rightBearing) || (approxBearing.distance1 + approxBearing.distance2) / 2.0 < (rightBearing.distance1 + rightBearing.distance2) / 2.0)
                        rightBearing = approxBearing;
                    end
                end
            end

            % Calculate the true forward bearing
            % Desmos Math Link: https://www.desmos.com/calculator/sqiqjkkxmg
            if (~isnan(leftBearing)) % (If a minimum left bearing exists)
                avgLeftDistance = (leftBearing.distance1 + leftBearing.distance2) / 2.0;
                avgLeftTheta = (leftBearing.theta1 + leftBearing.theta2) / 2.0;
                d0 = avgLeftDistance;
                t0 = avgLeftTheta;
            else
                d0 = 0.0;
                t0 = 0.0;
            end
            if (~isnan(rightBearing)) % (If a minimum right bearing exists)
                avgRightDistance = (rightBearing.distance1 + rightBearing.distance2) / 2.0;
                avgRightTheta = (rightBearing.theta1 + rightBearing.theta2) / 2.0;
                d1 = avgRightDistance;
                t1 = avgRightTheta;
            else
                d1 = 0.0;
                t1 = 0.0;
            end

            % Bearing will be NaN if there are no recorded sides. Will
            % calculate based on 1 side if a side is missing
            bearing = (180/pi) * acos((d1*cos(t1) - d0*cos(t0)) / (sqrt((d1*sin(t1)-d0*sin(t0))^2 + (d1*cos(t1)-d0*cos(t0))^2))) * sign(d1*sin(t1)-d0*sin(t0));
        end

        function minDistance = GetMinDistanceForward(rangeFinder)
            % Calculates the minimum distance to a forward wall
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            arguments (Output)
                minDistance double % The minimum distance to a forward wall
            end
            i = 0;
            forwardBearing = NaN;
            while (i < rangeFinder.lastScan.minima.length)
                extremaPoint = rangeFinder.lastScan.minima.Get(i);
                approxBearing = 90 - rad2deg((extremaPoint.theta1 + extremaPoint.theta2) / 2.0);
                if (approxBearing >= -45 && approxBearing <= 45) 
                    if (isnan(forwardBearing) || (approxBearing.distance1 + approxBearing.distance2) / 2.0 < (forwardBearing.distance1 + forwardBearing.distance2) / 2.0)
                        forwardBearing = approxBearing;
                    end
                end
                i = i + 1;
            end
            if (isnan(forwardBearing))
                minDistance = NaN; 
            else
                minDistance = min(forwardBearing.distance2, forwardBearing.distance1);
            end
        end

        function minDistance = GetMinDistanceLeft(rangeFinder)
            % Calculates the minimum distance to a left wall
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            arguments (Output)
                minDistance double % The minimum distance to a left wall
            end
            i = 0;
            leftBearing = NaN;
            while (i < rangeFinder.lastScan.minima.length)
                extremaPoint = rangeFinder.lastScan.minima.Get(i);
                approxBearing = 90 - rad2deg((extremaPoint.theta1 + extremaPoint.theta2) / 2.0);
                if (approxBearing < -45) 
                    if (isnan(leftBearing) || (approxBearing.distance1 + approxBearing.distance2) / 2.0 < (leftBearing.distance1 + leftBearing.distance2) / 2.0)
                        leftBearing = approxBearing;
                    end
                end
                i = i + 1;
            end
            if (isnan(leftBearing))
                minDistance = NaN; 
            else
                minDistance = min(leftBearing.distance2, leftBearing.distance1);
            end
        end
        
        function minDistance = GetMinDistanceRight(rangeFinder)
            % Calculates the minimum distance to a right wall
            arguments (Input)
                rangeFinder RangeFinder % The RangeFinder object
            end
            arguments (Output)
                minDistance double % The minimum distance to a right wall
            end
            i = 0;
            rightBearing = NaN;
            while (i < rangeFinder.lastScan.minima.length)
                extremaPoint = rangeFinder.lastScan.minima.Get(i);
                approxBearing = 90 - rad2deg((extremaPoint.theta1 + extremaPoint.theta2) / 2.0);
                if (approxBearing < -45) 
                    if (isnan(rightBearing) || (approxBearing.distance1 + approxBearing.distance2) / 2.0 < (rightBearing.distance1 + rightBearing.distance2) / 2.0)
                        rightBearing = approxBearing;
                    end
                end
                i = i + 1;
            end
            if (isnan(rightBearing))
                minDistance = NaN; 
            else
                minDistance = min(rightBearing.distance2, rightBearing.distance1);
            end
        end
    end
end