classdef TyreAnalysisPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREANALYSISPANEL Can visualize measurement data and model in axes.
    
    properties
        Measurements tydex.Measurement = tydex.Measurement.empty
    end
    properties (Access = private, Transient, NonCopyable)
        Grid                    matlab.ui.container.GridLayout
        ButtonsPlotType         matlab.ui.control.StateButton
        ButtonsGrid             matlab.ui.container.GridLayout
        ShowSidebarStateButton  matlab.ui.control.StateButton
        PlotCurvesPanel         ui.TyrePlotCurvesPanel
    end
    events (NotifyAccess = public)
        TyreModelChanged
    end
    methods (Access = private)
        function onModelChanged(obj, ~, event)
            model = event.Model;
            e = events.ModelChangedEventData(model);
            notify(obj.PlotCurvesPanel, 'TyreModelChanged', e)
        end
    end
    methods(Access = private)
        function onShowSidebarStateButtonValueChanged(obj, ~, event)
            show = event.Value;
            obj.PlotCurvesPanel.ShowSidebar = show;
        end
        function onButtonsPlotTypeValueChanged(obj, origin, ~)
            buttons = obj.ButtonsPlotType;
            buttonPressed = origin;
            I = buttons == buttonPressed;
            set(buttons(~I), 'Value', false)
            set(buttons(~I), 'Enable', 'on')
            set(buttons(I), 'Value', true)
            set(buttons(I), 'Enable', 'off')
        end
    end
    methods(Access = protected)
        function setupPlot(obj)
            obj.PlotCurvesPanel = ui.TyrePlotCurvesPanel(obj.Grid);
        end
        function setupGrid(obj)
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {22,'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 0*ones(1,4), ...
                'Scrollable', false);
        end
        function setupButtons(obj)
            obj.ButtonsGrid = uigridlayout(obj.Grid, ...
                'RowHeight', {22}, ...
                'ColumnWidth', {110, 110, '1x', 25}, ...
                'ColumnSpacing', 10, ...
                'Padding', zeros(1,4));
            
            btn1 = uibutton(obj.ButtonsGrid, 'state', ...
                'Text', 'Tyre Curves', ...
                'Icon', 'plot_curves_icon.svg', ...
                'Value', true, ...
                'Enable', 'off');
            btn2 = uibutton(obj.ButtonsGrid, 'state', ...
                'Text', 'Friction Ellipse', ...
                'Icon', 'plot_friction_ellipse_icon.svg', ...
                'Value', false, ...
                'Enable', 'on');
            obj.ButtonsPlotType = [btn1 btn2];
            set(obj.ButtonsPlotType, ...
                'ValueChangedFcn', @obj.onButtonsPlotTypeValueChanged)
            
            obj.ShowSidebarStateButton = ...
                uibutton(obj.ButtonsGrid, 'state', ...
                'Icon', 'gears-solid.svg', ...
                'Text', char.empty, ...
                'Value', true, ...
                'Tooltip', 'Toggles visibility of axes sidebar', ...
                'ValueChangedFcn', @obj.onShowSidebarStateButtonValueChanged);
            obj.ShowSidebarStateButton.Layout.Column = ...
                numel(obj.ButtonsGrid.ColumnWidth);
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onModelChanged);
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            setupGrid(obj)
            setupButtons(obj)
            setupPlot(obj)
            setupListeners(obj)
        end
        function update(obj)
        end
    end
end
