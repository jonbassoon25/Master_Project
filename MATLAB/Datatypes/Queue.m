classdef Queue < handle
    % A queue datatype since MATLAB doens't implement one
    %   and arrays/vectors are inefficient for resizing

    properties (Access = protected)
        head
        tail
    end

    properties (Access = public)
        length
    end

    methods
        function stack = Queue()
            % Construct an instance of this class
            stack.head = [];
            stack.tail = [];
            stack.length = 0;
        end

        function Enqueue(queue, value)
            % Adds an element to the rear of the queue
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
            if (queue.length == 0)
                value = [];
            else
                value = queue.head.value;
                queue.head = queue.head.next;
                queue.length = queue.length - 1;
            end
        end

        function value = Get(queue, index)
            % Returns the value of an element at the given index
            if (index >= queue.length)
                error("Index %d out of bounds for length %d", index, queue.length);
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
            if (index >= queue.length)
                error("Index %d out of bounds for length %d", index, queue.length);
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