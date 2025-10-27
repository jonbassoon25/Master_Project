classdef Keyboard < handle
    % A keyboard user input interface
    
    properties (Constant, Access=private)
        DEBUG logical = true % Display debug information at runtime
    end

    properties (Access = protected)
        keysDown LinkedList % A list of the currently pressed keys
        inputWindow % The input window for key presses
    end

    methods (Access = protected)
        function PressKey(keyboard, key)
            % Called when a key press needs to be recorded
            arguments (Input)
                keyboard Keyboard % This Keyboard object
                key               % The value of the key that was pressed
            end
            try
                if (~keyboard.keysDown.Contains(key))
                    keyboard.keysDown.Append(key);
                    if (keyboard.DEBUG) 
                        fprintf("Press %s, list length: %d\n", key, keyboard.keysDown.length);
                    end
                end
            catch exception
                keyboard.keysDown.Clear();
            end
        end

        function ReleaseKey(keyboard, key)
            % Called when a key release needs to be recorded
            arguments (Input)
                keyboard Keyboard % This Keyboard object
                key               % The value of the key that was released
            end
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
            % Initializes the properties of a new Keyboard object
            arguments (Output)
                keyboard Keyboard % The constructed Keyboard object
            end
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
            % Determines if a keyboard key is currently being pressed
            arguments (Input)
                keyboard Keyboard % This Keyboard object
                key               % The value of the key to check
            end
            arguments (Output)
                bool logical % Is the key pressed or not
            end
            bool = keyboard.keysDown.Contains(key);
        end

        function delete(keyboard)
            close(keyboard.inputWindow);
        end
    end
end