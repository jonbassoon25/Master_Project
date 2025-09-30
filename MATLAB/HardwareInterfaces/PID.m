% Reference: 
%   https://developer.wildernesslabs.co/Hardware/Reference/Algorithms/Proportional_Integral_Derivative/Standard_PID_Algorithm/

classdef PID < handle
    % A PID controller to be used for many applications

    properties (Access = protected)
        % Error tracker values
        integralErrorValues
        integralTimeValues
        derivativeErrorValues
        derivativeTimeValues
        
        integralErrorSum
        integralTimeSum
        derivativeErrorSum
        derivativeTimeSum

        proportionalErrorValue

        % Proportional Gain
        pGain

        % Time cutoffs
        targetIntegralTime
        targetDerivativeTime
    end


    methods
        function pid = PID(pGain, integralTime, derivativeTime)
            % Construct an instance of this class
            pid.pGain = pGain;
            pid.targetIntegralTime = integralTime;
            pid.targetDerivativeTime = derivativeTime;

            pid.reset();
        end

        function reset(pid)
            % Resets this PID to its default state
            pid.integralErrorValues = Queue();
            pid.integralTimeValues = Queue();
            pid.derivativeErrorValues = Queue();
            pid.derivativeTimeValues = Queue();

            pid.integralErrorSum = 0;
            pid.integralTimeSum = 0;
            pid.derivativeErrorSum = 0;
            pid.derivativeTimeSum = 0;

            pid.proportionalErrorValue = 0;
        end

        function updateErrorState(pid, error, ellapsedTime)
            % Update the error state of this PID with a
            %   new Integral Error Value
            %   new Proportional Error Value
            %   new Derivative Error Value

            % Update proportional error value
            pid.proportionalErrorValue = error;

            integralError = error * ellapsedTime;
            derivativeError = 
            
            % Update Integral Values
            pid.integralErrorValues.Enqueue(newIEV);
            pid.integralErrorSum = pid.integralErrorSum + newIEV;
            pid.integralTimeValues.Enqueue(ellapsedTime);
            pid.integralTimeSum = pid.integralTimeSum + ellapsedTime;
            while (pid.integralTimeSum > pid.targetIntegralTime)
                pid.integralErrorSum = pid.integralErrorSum - pid.integralErrorValues.Dequeue();
                pid.integralTimeSum = pid.integralTimeSum - pid.integralTimeValues.Dequeue();
            end

            % Update Derivative Values
            pid.derivativeErrorValues.Enqueue(newDEV);
            pid.derivativeErrorSum = pid.derivativeErrorSum + newDEV;
            pid.derivativeTimeValues.Enqueue(ellapsedTime);
            pid.derivativeTimeSum = pid.derivativeTimeSum + ellapsedTime;
            while (pid.derivativeTimeSum > pid.targetDerivativeTime)
                pid.derivativeErrorSum = pid.derivativeErrorSum - pid.derivativeErrorValues.Dequeue();
                pid.derivativeTimeSum = pid.derivativeTimeSum - pid.derivativeTimeValues.Dequeue();
            end
        end

        function controlOutput = calculateControlOutput(pid)
            % Calculates the control output of this PID in the range
            %   -1:1 inclusive
            proportionalError = pid.proportionalErrorValue;

            if (pid.targetIntegralTime ~= 0)
                integralError = pid.integralErrorSum / pid.targetIntegralTime;
            else
                integralError = 0;
            end

            if (pid.derivativeTimeSum ~= 0 && pid.targetDerivativeTime ~= 0)
                derivativeError = pid.derivativeErrorSum / pid.derivativeTimeSum * pid.targetDerivativeTime;
            else
                derivativeError = 0;
            end

            controlOutput = pid.pGain * (proportionalError + integralError + derivativeError);
        end
    end
end