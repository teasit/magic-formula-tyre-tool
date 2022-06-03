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
            sidebar = obj.SidePanel;
            axes = obj.Axes;
            if show
                set(sidebar, 'Visible', 'on')
                axes.Layout.Column = 1;
            else
                set(sidebar, 'Visible', 'off')
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
            obj.SidePanel = uipanel(obj.MainGrid);
            obj.SidePanel.Layout.Column = 2;
            
            obj.SidePanelGrid = uigridlayout(obj.SidePanel, ...
                'RowHeight', repmat({'fit'}, 1, 2), ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4), ...
                'Scrollable', true);
        end
        function setupPlotSettings(obj)
            p = uipanel(obj.SidePanelGrid, ...
                'Title', 'Plot Settings', ...
                'BorderType', 'none');
            g = uigridlayout(p, ...
                'RowHeight', repmat({'fit'}, 1, 6), ...
                'ColumnWidth', {'fit', 'fit', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 10*ones(1,4), ...
                'Scrollable', false);
            uibutton(g, 'Text', '<PLACEHOLDER>');
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
            setupPlotSettings(obj)
            setupListeners(obj)
        end
        function update(obj)
            updateSidebarState(obj)
        end
    end
end
