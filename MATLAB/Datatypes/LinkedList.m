classdef LinkedList < handle
    % A linked list data type

    properties (Access = protected)
        head % The first LinkedListElement of the linked list or [] if there is none
        tail % The last LinkedListElement of the linked list or [] if there is none
    end

    properties (Access = public)
        length uint32 % The length of the linked list
    end

    methods (Access = protected)
        function CheckOutOfRange(list, index)
            % Throws an error if the provided index is out of range
            arguments (Input)
                list LinkedList % This LinkedList Object
                index uint32    % The index to check
            end

            if (index < 0 || index >= list.length) 
                error("Index %d out of range for linked list of length %d", index, list.length);
            end
        end
    end

    methods (Access = public)
        function list = LinkedList()
            % Initializes the properties of a new LinkedList object
            arguments (Output)
                list LinkedList % This LinkedList Object
            end
            list.head = [];
            list.tail = [];
            list.length = 0;
        end

        function value = Get(list, index)
            % Gets the value at the provided index of this linked list
            arguments(Input)
                list LinkedList % This LinkedList Object
                index uint32    % The index to retrieve the value of
            end
            arguments(Output)
                value
            end
            
            % Check if the index is out of range
            list.CheckOutOfRange(index);

            % If the index is of the last element of the linked list
            if (index + 1 == list.length) 
                % Get the value of the last element of the linked list
                value = list.tail.value;
            else
                % Get the value of the provided index of the linked list
                i = 0;
                curNode = list.head;
                while (i < index)
                    curNode = curNode.next;
                    i = i + 1;
                end
                value = curNode.value;
            end
        end

        function Set(list, index, value)
            % Sets the value at the provided index of this linked list to the provided value
            arguments (Input)
                list LinkedList % This LinkedList Object
                index uint32    % The index of the linked list to set the value of
                value           % The value to set the provided index of the linked list to
            end

            % Check if the index is out of range
            list.CheckOutOfRange(index);

            % If the index is of the last element of the linked list
            if (index + 1 == list.length) 
                % Set the value of the last element of the linked list
                list.tail.value = value;
            else
                % Set the value of the provided index of the linked list
                i = 0;
                curNode = list.head;
                while (i < index)
                    curNode = curNode.next;
                    i = i + 1;
                end
                curNode.value = value;
            end
        end

        function Append(list, value)
            % Adds a new element to the end of the linked list
            arguments (Input)
                list LinkedList % This LinkedList Object
                value           % The value of the new linked list element
            end
            newNode = LinkedListElement(value);
            if (isempty(list.head))
                list.head = newNode;
                list.tail = newNode;
            else
                list.tail.next = newNode;
                list.tail = list.tail.next;
            end
            list.length = list.length + 1;
        end

        function Insert(list, index, value)
            % Inserts a new element to the provided index of the linked list
            arguments (Input)
                list LinkedList % This LinkedList Object
                index uint32    % The index of the new element
                value           % The value of the new element
            end

            % Check if the index is out of range
            if (index < 0 || index > list.length) 
                error("Index %d out of range for length %d", index, list.length);
            end

            % If the index is the end of the list
            if (index == list.length) 
                list.Append(value);
            % If the index is the beginning of the list
            elseif (index == 0)
                newHead = LinkedListElement(value);
                newHead.next = list.head;
                list.head = newHead;
            else
                curNode = list.head;
                i = 0;
                while i + 1 < index
                    curNode = curNode.next;
                    i = i + 1;
                end
                newNode = LinkedListElement(value);
                newNode.next = curNode.next;
                curNode.next = newNode;
            end
            list.length = list.length + 1;
        end

        function Clear(list)
            % Removes all elements from this linked list
            arguments (Input)
                list LinkedList % This LinkedList Object
            end
            list.head = [];
            list.tail = [];
            list.length = 0;
        end

        function bool = Contains(list, value)
            % Determines if any elements of the linked list have a value equal to the provided value
            arguments (Input)
                list LinkedList % This LinkedList Object
                value           % The value to check for
            end
            curNode = list.head;
            bool = false;
            while ~isempty(curNode)
                if (curNode.value == value)
                    bool = true;
                    break;
                end
                curNode = curNode.next;
            end
        end

        function Remove(list, value)
            % Removes all elements of the linked list with a value equal to the provided value
            arguments (Input)
                list LinkedList % This LinkedList Object
                value           % The value to remove
            end
            % While the head of the linked list has a value equal to the
            % provided value
            while (~isempty(list.head) && (list.head.value == value))
                list.head = list.head.next;
                list.length = list.length - 1;
                if (list.length == 0)
                    list.tail = [];
                end
            end
            % While the tail of the linked list has a value equal to the
            % provided value
            %    Note: The head of the linked list will always have a value
            %    that isn't the value to remove if the tail has a value
            while (~isempty(list.tail) && list.tail.value == value)
                curNode = list.head;
                while ~isempty(curNode.next.next)
                    curNode = curNode.next;
                end
                curNode.next = [];
                list.tail = curNode;
                list.length = list.length - 1;
            end
            % Remove all elements with a value equal to the value to remove
            curNode = list.head;
            while (~isempty(curNode) && ~isempty(curNode.next))
                if (curNode.next.value == value)
                    curNode.next = curNode.next.next;
                    list.length = list.length - 1;
                end
                curNode = curNode.next;
            end
        end
    end
end