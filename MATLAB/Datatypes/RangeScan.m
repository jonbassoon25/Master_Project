classdef RangeScan < handle
    %RANGESCAN Summary of this class goes here
    %   Detailed explanation goes here

    properties (Access = protected)
        minima LinkedList      % The minima of the scan, sorted by ascending theta
        maxima LinkedList      % The maxima of the scan, sorted by ascending theta
        undefRanges LinkedList % The undefined ranges of the scan, sorted by ascending theta
    end

    methods (Access = public)
        function scan = RangeScan()
            arguments (Output)
                scan RangeScan
            end
            scan.minima = LinkedList();
            scan.maxima = LinkedList();
            scan.undefRanges = LinkedList();
        end

        function addMinima(scan, theta1, distance1, theta2, distance2)
            arguments (Input)
                scan RangeScan
                theta1 double
                distance1 double
                theta2 double
                distance2 double
            end
            newMinimum = RangeScanExtremaPoint("min", theta1, theta2, distance1, distance2);
            inserted = false;
            i = 0;
            while i + 1 < scan.minima.length
                if (scan.minima.Get(i).theta > newMinimum.theta)
                    scan.minima.Insert(i, newMinimum);
                    inserted = true;
                    break;
                end
                i = i + 1;
            end
            if (~inserted)
                scan.minima.Append(newMinimum);
            end
        end

        function addMaxima(scan, theta1, distance1, theta2, distance2)
            arguments (Input)
                scan RangeScan
                theta1 double
                distance1 double
                theta2 double
                distance2 double
            end
            newMaximum = RangeScanExtremaPoint("max", theta1, theta2, distance1, distance2);
            inserted = false;
            i = 0;
            while i + 1 < scan.maxima.length
                if (scan.maxima.Get(i).theta > newMaximum.theta)
                    scan.maxima.Insert(i, newMaximum);
                    inserted = true;
                    break;
                end
                i = i + 1;
            end
            if (~inserted)
                scan.maxima.Append(newMaximum);
            end
        end

        function addUndefinedRange(scan, lastDefinedTheta, firstUndefinedTheta, lastUndefinedTheta, nextDefinedTheta)
            arguments (Input)
                scan RangeScan
                lastDefinedTheta double
                firstUndefinedTheta double
                lastUndefinedTheta double
                nextDefinedTheta double
            end
            start = (lastDefinedTheta + firstUndefinedTheta) / 2;
            startError = abs(lastDefinedTheta - firstUndefinedTheta) / 2;
            stop = (lastUndefinedTheta + nextDefinedTheta) / 2;
            stopError = abs(lastUndefinedTheta - nextDefinedTheta) / 2;
            
            newUndefinedRange = RangeScanRange(start, startError, stop, stopError);
            inserted = false;
            i = 0;
            while i + 1 < scan.undefRanges.length
                if (scan.undefRanges.Get(i).start > newUndefinedRange.start)
                    scan.undefRanges.Insert(i, newUndefinedRange);
                    inserted = true;
                    break;
                end
                i = i + 1;
            end
            if (~inserted)
                scan.undefRanges.Append(newUndefinedRange);
            end
        end
    end
end