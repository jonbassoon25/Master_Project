classdef Keyboard < handle
    % A keyboard user input interface
    
    properties (Constant, Access=private)
        DEBUG logical = false % Display debug information at runtime
    end

    properties (Access = protected)
        keysDown LinkedList
        inputWindow
    end

    methods (Access = protected)
        function PressKey(keyboard, key)
            try
                if (~keyboard.keysDown.Contains(key))
                    keyboard.keysDown.Append(key);
                    %fprintf("%s\n", keyboard.keysDown.Get(keyboard.keysDown.length - 1));
                    if (keyboard.DEBUG) 
                        fprintf("Press %s, list length: %d\n", key, keyboard.keysDown.length);
                    end
                end
            catch exception
                keyboard.keysDown.Clear();
            end
        end

        function ReleaseKey(keyboard, key)
            try
                keyboard.keysDown.Remove(key);
                if (keyboard.DEBUG) 
                    fprintf("Release %s, list length: %d\n", key, keyboard.keysDown.length);
                end
            catch exception
                keyboard.keysDown.Clear();
            end
        end
    end

    methods (Access = public)
        function keyboard = Keyboard()
            % Initialize the keyboard properties
            keyboard.keysDown = LinkedList();
            keyboard.inputWindow = figure;

            % Setup keyboard event callbacks
            set(keyboard.inputWindow, 'KeyPressFcn', @(h_obj, evt) keyboard.PressKey(evt.Key));
            set(keyboard.inputWindow, 'KeyReleaseFcn', @(h_obj, evt) keyboard.ReleaseKey(evt.Key));

            % Create text
            text(1) = {'Click on this window and press any key to control the robot.'};
            textbox = annotation(keyboard.inputWindow, 'textbox',[0,0,1,1]);
            set(textbox,'String', text);

        end

        function bool = IsPressed(keyboard, key)
            bool = keyboard.keysDown.Contains(key);
        end

        function delete(keyboard)
            close(keyboard.inputWindow);
        end
    end
end