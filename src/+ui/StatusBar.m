classdef StatusBar < matlab.ui.componentcontainer.ComponentContainer
    %STATUSBAR Summary of this class goes here
    %   Detailed explanation goes here
    
    events (HasCallbackProperty, NotifyAccess = protected)
    end
    properties
        StatusText char
        StatusType enum.StatusType = enum.StatusType.Normal
    end
    properties (Access = private, Transient, NonCopyable)
        GridMain        matlab.ui.container.GridLayout
        Label           matlab.ui.control.Label
        ButtonExpand    matlab.ui.control.Button
    end
    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 600 300];
            obj.GridMain = uigridlayout(obj, ...
                'ColumnWidth', {'fit','1x'}, ...
                'RowHeight', {'1x'}, ...
                'Padding', [0 0 0 0]);
            obj.ButtonExpand = uibutton(obj.GridMain, ...
                'Icon', 'angle-up-solid.svg', ...
                'IconAlignment', 'center', ...
                'Text', char.empty);
            obj.Label = uilabel(obj.GridMain, ...
                'Text', char.empty, ...
                'WordWrap', 'off', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center');
        end
        function update(obj)
            text = obj.StatusText;
            switch obj.StatusType
                case enum.StatusType.Normal
                    color = 'black';
                case enum.StatusType.Success
                    color = 'green';
                case enum.StatusType.Info
                    color = 'blue';
                case enum.StatusType.Warning
                    color = '#EDB120';
                case enum.StatusType.Error
                    color = 'red';
                otherwise
                    return
            end
            set(obj.Label, 'Text', text)
            set(obj.Label, 'FontColor', color)
        end
    end
end
