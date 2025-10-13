classdef LinkedList < handle
    % A linked list datastructure

    properties (Access = protected)
        head
        tail
    end

    properties (Access = public)
        length
    end

    methods (Access = protected)
        function CheckOutOfRange(list, index)
            if (index < 0 || index >= list.length) 
                error("Index %d out of range for length %d", index, list.length);
            end
        end
    end

    methods (Access = public)
        function list = LinkedList()
            % Construct an instance of this class
            list.head = [];
            list.tail = [];
            list.length = 0;
        end

        function value = Get(list, index)
            list.CheckOutOfRange(index);
            if (index == list.length - 1) 
                value = list.tail.value;
            else
                curNode = list.head;
                for i = 0:index - 1
                    curNode = curNode.next;
                end
                value = curNode.value;
            end
        end

        function Set(list, index, value)
            list.CheckOutOfRange(index);
            if (index == list.length - 1) 
                list.tail.value = value;
            else
                curNode = list.head;
                for i = 0:index - 1
                    curNode = curNode.next;
                end
                curNode.value = value;
            end
        end

        function Append(list, value)
            newNode = LinkedListElement(value);
            if (isempty(list.head))
                list.head = newNode;
            end
            list.tail.next = newNode;
            list.tail = list.tail.next;
            list.length = list.length + 1;
        end

        function Insert(list, index, value)
            if (index < 0 || index > list.length) 
                error("Index %d out of range for length %d", index, list.length);
            elseif (index == list.length) 
                list.Append(value);
            elseif (index == 0)
                newHead = LinkedListElement(value);
                newHead.next = list.head;
                list.head = newHead;
            else
                curNode = list.head;
                for i = 0:index - 2
                    curNode = curNode.next;
                end
                newNode = LinkedListElement(value);
                newNode.next = curNode.next;
                curNode.next = newNode;
            end
            list.length = list.length + 1;
        end

        function Clear(list)
            list.head = [];
            list.tail = [];
            list.length = 0;
        end

        function bool = Contains(list, value) 
            curNode = list.head;
            bool = false;
            for i = 0:list.length - 1
                if (curNode.value == value)
                    bool = true;
                    break;
                else
                    curNode = curNode.next;
                end
            end
        end

        function Remove(list, value)
            % Removes all instances of value in the linked list
            if (~isempty(list.head) && list.head.value == value)
                list.head = list.head.next;
                list.length = list.length - 1;
                if (list.length == 0)
                    list.tail = [];
                end
            elseif (~isempty(list.tail) && list.tail.value == value)
                curNode = list.head;
                for i = 0:list.length - 2
                    curNode = curNode.next;
                end
                list.tail = curNode;
            end
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