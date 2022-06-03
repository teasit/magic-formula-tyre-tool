classdef TyrePlotFrictionEllipsePanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREPLOTFRICTIONELLIPSEPANEL Plots friction ellipse of tyre model.
    
    properties
        Model mftyre.v62.Model = mftyre.v62.Model.empty
        ShowSidebar logical = true
    end
    properties (Access = private, Transient, NonCopyable)
        MainGrid                    matlab.ui.container.GridLayout
        Axes                        ui.FrictionEllipseAxes
        SidePanel                   matlab.ui.container.Panel
        SidePanelGrid               matlab.ui.container.GridLayout
    end
    events (NotifyAccess = public)
        TyreModelChanged
    end
    methods (Access = private)
        function onModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
            obj.Axes.Model = model;
        end
    end
    methods(Access = protected)
        function updateSidebarState(obj)
            show = obj.ShowSidebar;
            grid = obj.SidePanelGrid;
            axes = obj.Axes;
            if show
                set(grid, 'Visible', 'on')
                axes.Layout.Column = 1;
            else
                set(grid, 'Visible', 'off')
                axes.Layout.Column = [1 2];
            end
        end
    end
    methods(Access = protected)
        function setupMainGrid(obj)
            obj.MainGrid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 0*ones(1,4), ...
                'Scrollable', false);
        end
        function setupSidePanel(obj)
            obj.SidePanelGrid = uigridlayout(obj.MainGrid, ...
                'RowHeight', repmat({'fit'}, 1, 2), ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4), ...
                'Scrollable', true);
            obj.SidePanelGrid.Layout.Column = 2;
        end
        function setupAxes(obj)
            ax = ui.FrictionEllipseAxes(obj.MainGrid, ...
                'Model', obj.Model);
            obj.Axes = ax;
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onModelChanged);
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            setupMainGrid(obj)
            setupAxes(obj)
            setupSidePanel(obj)
            setupListeners(obj)
        end
        function update(obj)
            updateSidebarState(obj)
        end
    end
end
