classdef LinkedListElement < handle
    % A linked-list element that is part of a stack

    properties (Access = public)
        value
        next
    end

    methods
        function element = LinkedListElement(value)
            % Construct an instance of this class
            element.value = value;
            element.next = [];
        end
    end
end