classdef PID < handle
    % A Proportional Integral Derivative Controller using the standard form of the PID algorithm

    properties (Access = protected)
        integralErrorValues Queue     % A queue of the last n integral error values
        integralTimeValues Queue      % A queue of the measurement times of the recorded integral error values
        derivativeErrorValues Queue   % A queue of the last n derivative error values
        derivativeTimeValues Queue    % A queue of the measurement times of the recorded derivative error values
        integralErrorSum double       % The sum of the recorded integral error values
        integralTimeSum double        % The sum of the recorded integral measurement times
        derivativeErrorSum double     % The sum of the recorded derivative error values
        derivativeTimeSum double      % The sum of the recorded derivative measurment times
        proportionalErrorValue double % The current proportional error value
        lastPEV double                % The last proportional error value
        pGain double                  % The proportional gain constant
        targetIntegralTime double     % The ideal sum of the recorded integral times
        targetDerivativeTime double   % The ideal sum of the recorded derivative times
    end

    methods
        function pid = PID(pGain, integralTime, derivativeTime)
            % Initializes the properties of a new PID object
            arguments (Input)
                pGain double          % The proportional gain constant to use
                integralTime double   % The target integral time to use
                derivativeTime double % The target derivative time to use
            end
            arguments (Output)
                pid PID % The constructed PID object
            end
            pid.pGain = pGain;
            pid.targetIntegralTime = integralTime;
            pid.targetDerivativeTime = derivativeTime;

            pid.reset();
        end

        function reset(pid)
            % Resets the properties of this PID to their default values
            arguments (Input)
                pid PID % The PID object
            end
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
            % Update the error state of the PID controller
            arguments (Input)
                pid PID             % The PID object
                error double        % The current error of the control variable
                ellapsedTime double % The time since the last measurement
            end
            % Update proportional error value
            lastError = pid.proportionalErrorValue;
            pid.proportionalErrorValue = error;

            integralError = error * ellapsedTime;
            derivativeError = error - lastError;
            
            % Update Integral Values
            pid.integralErrorValues.Enqueue(integralError);
            pid.integralErrorSum = pid.integralErrorSum + integralError;
            pid.integralTimeValues.Enqueue(ellapsedTime);
            pid.integralTimeSum = pid.integralTimeSum + ellapsedTime;
            while (pid.integralTimeSum > pid.targetIntegralTime)
                pid.integralErrorSum = pid.integralErrorSum - pid.integralErrorValues.Dequeue();
                pid.integralTimeSum = pid.integralTimeSum - pid.integralTimeValues.Dequeue();
            end

            % Update Derivative Values
            pid.derivativeErrorValues.Enqueue(derivativeError);
            pid.derivativeErrorSum = pid.derivativeErrorSum + derivativeError;
            pid.derivativeTimeValues.Enqueue(ellapsedTime);
            pid.derivativeTimeSum = pid.derivativeTimeSum + ellapsedTime;
            while (pid.derivativeTimeSum > pid.targetDerivativeTime && pid.derivativeErrorValues.length > 1)
                pid.derivativeErrorSum = pid.derivativeErrorSum - pid.derivativeErrorValues.Dequeue();
                pid.derivativeTimeSum = pid.derivativeTimeSum - pid.derivativeTimeValues.Dequeue();
            end
        end

        function controlOutput = calculateControlOutput(pid)
            % Calculates the control output of this PID
            arguments (Input)
                pid PID % The PID object
            end
            arguments (Output)
                controlOutput double % The control output in the range [-1, 1]
            end
            
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

            controlOutput = pid.pGain * cast((proportionalError + integralError + derivativeError), "double");

            fprintf("Raw control out: %f\n", controlOutput);
    
            if (controlOutput > 1) 
                % Stop windup behavior if the max output is reached
                pid.integralErrorSum = pid.integralErrorSum - pid.integralErrorValues.Get(pid.integralErrorValues.length - 1);
                pid.integralErrorValues.Set(pid.integralErrorValues.length - 1, 0);

                controlOutput = 1;
            elseif (controlOutput < -1)
                % Stop windup behavior if the max output is reached
                pid.integralErrorSum = pid.integralErrorSum - pid.integralErrorValues.Get(pid.integralErrorValues.length - 1);
                pid.integralErrorValues.Set(pid.integralErrorValues.length - 1, 0);

                controlOutput = -1;
            end

            fprintf("Requesting %.2f%% motor power: %f(%0.2f, %0.2f, %0.2f)\n", controlOutput * 100, pid.pGain, proportionalError, integralError, derivativeError);
        end
    end
end