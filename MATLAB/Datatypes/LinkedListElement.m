classdef LinkedListElement < handle
    % A generic element of a linked list

    properties (Access = public)
        value 
        next % The next LinkedListElement or [] if there is none
    end

    methods
        function element = LinkedListElement(value)
            % Initializes the properties of a new LinkedListElement object
            arguments (Input)
                value
            end
            arguments (Output)
                element LinkedListElement
            end
            element.value = value;
            element.next = [];
        end
    end
end