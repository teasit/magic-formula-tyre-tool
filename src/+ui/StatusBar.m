classdef StatusBar < matlab.ui.componentcontainer.ComponentContainer
    %STATUSBAR
    
    properties
        Text char
    end
    
    properties (Access = private, Transient, NonCopyable)
        Label matlab.ui.control.Label
    end
    
    methods (Access = protected)
        function setup(obj)
            g = uigridlayout(obj, ...
                'RowHeight', {'fit'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', 5*ones(1,4));
            
            obj.Label = uilabel(g, 'Text', obj.Text);
        end
        function update(obj)
            set(obj.Label, 'Text', obj.Text)
        end
    end
end
