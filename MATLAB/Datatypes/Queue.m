classdef Queue < handle
    % A Queue Datatype

    properties (Access = protected)
        head % The first element of the queue or [] if there is none
        tail % The last element of the queue or [] if there is none
    end

    properties (Access = public)
        length uint32 % The length of the queue
    end

    methods (Access = public)
        function queue = Queue()
            % Initializes the properties of a new Queue object
            arguments (Output)
                queue Queue % This Queue Object
            end
            queue.head = [];
            queue.tail = [];
            queue.length = 0;
        end

        function Enqueue(queue, value)
            % Adds a new element to the back of the queue
            arguments (Input)
                queue Queue % This Queue Object
                value       % The value of the new element
            end
            nextElement = LinkedListElement(value);
            if (isempty(queue.head))
                queue.head = nextElement;
            end
            if (~isempty(queue.tail))
                queue.tail.next = nextElement;
            end
            queue.tail = nextElement;
            queue.length = queue.length + 1;
        end

        function value = Dequeue(queue)
            % Pops an element from the front of the queue
            arguments (Input)
                queue Queue % This Queue Object
            end
            arguments (Output)
                value % The value of the removed element or [] if there is none
            end
            if (queue.length == 0)
                value = [];
            else
                value = queue.head.value;
                queue.head = queue.head.next;
                queue.length = queue.length - 1;
            end
        end

        function value = Get(queue, index)
            % Get the value of the element at the provided index
            arguments (Input)
                queue Queue  % This Queue Object
                index uint32 % The index to retrieve the value of
            end
            if (index >= queue.length)
                error("Index %d out of bounds for queue of length %d", index, queue.length);
            elseif (index == queue.length - 1)
                value = queue.tail.value;
            else
                current = queue.head;
                for i = 1:index
                    current = current.next;
                end
                value = current.value;
            end
        end

        function Set(queue, index, value)
            % Sets the value at the provided index of this linked list to the provided value
            arguments (Input)
                queue Queue  % This Queue Object
                index uint32 % The index of the queue to set the value of
                value        % The value to set the provided index of the queue to
            end
            if (index >= queue.length)
                error("Index %d out of bounds for queue of length %d", index, queue.length);
            elseif (index == queue.length - 1)
                queue.tail.value = value;
            else
                current = queue.head;
                for i = 1:index
                    current = current.next;
                end
                current.value = value;
            end
        end
    end
end