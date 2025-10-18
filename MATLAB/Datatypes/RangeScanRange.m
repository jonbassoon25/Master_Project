classdef RangeScanRange < handle
    % A range on the range scan's interval

    properties (Access = public)
        start double
        stop double
        startError double
        stopError double
    end

    methods
        function range = RangeScanRange(start, startError, stop, stopError)
            % Construct an instance of this class
            arguments (Input)
                start double
                startError double
                stop double
                stopError double
            end
            arguments (Output)
                range RangeScanRange
            end
            range.start = start;
            range.stop = stop;
            range.startError = startError;
            range.stopError = stopError;
        end
    end
end