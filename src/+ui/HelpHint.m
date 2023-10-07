classdef HelpHint < matlab.ui.componentcontainer.ComponentContainer
    %HELPHINT Clickable and hoverable help icon. Clicking executes custom
    %callback. Can be used to open HTML file in browser for example.
    
    properties
        Icon char = 'circle-info-solid.svg'
        Tooltip char = 'Add Tooltip here'
        ClickedFcn function_handle = function_handle.empty
    end
    
    properties (Access = private)
        Image matlab.ui.control.Image
    end
    
    properties (Access = private, Transient, NonCopyable)
    end
    methods (Access = protected)
        function setup(obj)
            s = settings.LayoutSettings();
            h = s.DefaultButtonHeight;
            grid = uigridlayout(obj, ...
                'RowHeight', h, ...
                'ColumnWidth', h, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4));
            
            obj.Image = uiimage(grid, ...
                'ImageSource', obj.Icon, ...
                'Tooltip', obj.Tooltip, ...
                'ImageClickedFcn', obj.ClickedFcn);
        end
        function update(obj)
            obj.Image.Tooltip = obj.Tooltip;
            obj.Image.ImageClickedFcn = obj.ClickedFcn;
            obj.Image.ImageSource = obj.Icon;
        end
    end
end
