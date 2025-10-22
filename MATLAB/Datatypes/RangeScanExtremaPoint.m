classdef RangeScanExtremaPoint < handle
    % An extrema point of a scan range's interval

    properties (Access = public)
        type string % Type of the extrema point (max, min or undefined)
        theta double
        distance double
        thetaError double
        distanceError double
    end

    methods
        function point = RangeScanExtremaPoint(type, theta1, theta2, distance1, distance2)
            % Construct an instance of this class
            arguments (Input)
                type string
                theta1 double
                theta2 double
                distance1 double
                distance2 double
            end
            arguments (Output)
                point RangeScanExtremaPoint
            end
            point.type = type;
            point.theta = (theta2 + theta1) / 2.0;
            point.distance = (distance2 + distance1) / 2.0;
            point.thetaError = abs(theta2 - theta1) / 2.0;
            point.distanceError = abs(distance2 - distance1) / 2.0;
        end
    end
end