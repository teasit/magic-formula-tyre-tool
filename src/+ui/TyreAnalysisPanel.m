classdef TyreAnalysisPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREANALYSISPANEL Can visualize measurement data and model in axes.
    
    properties
        Measurements tydex.Measurement = tydex.Measurement.empty
        Model magicformula.Model = magicformula.v62.Model.empty
    end
    properties (Access = private, Transient, NonCopyable)
        Grid                        matlab.ui.container.GridLayout
        GridPlot                    matlab.ui.container.GridLayout
        ButtonsPlotType             matlab.ui.control.StateButton
        ButtonsGrid                 matlab.ui.container.GridLayout
        ShowSidebarStateButton      matlab.ui.control.StateButton
        Plot                   matlab.ui.componentcontainer.ComponentContainer
    end
    properties (Access = protected)
        Settings settings.AppSettings
        ButtonsGridColumnWidthWithText = [repmat({110}, 1, 2) {'1x' 110}];
        ButtonsGridColumnWidthOnlyIcon = [repmat({25}, 1, 2) {'1x' 25}];
        ButtonsTexts cell
    end
    events (NotifyAccess = public)
        TyreModelChanged
        TyreDataChanged
    end
    methods (Access = private)
        function onModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
            e = events.ModelChangedEventData(model);
            notify(obj.Plot, 'TyreModelChanged', e)
        end
        function onDataChanged(obj, ~, event)
            measurements = event.Measurements;
            obj.Measurements = measurements;
            e = events.TyreMeasurementsChanged(measurements);
            notify(obj.Plot, 'TyreDataChanged', e)
        end
    end
    methods(Access = private)
        function onShowSidebarStateButtonValueChanged(obj, ~, event)
            showSidebar = event.Value;
            s = obj.Settings.View.TyreAnalysisPanel;
            s.ShowSidebar = showSidebar;
        end
        function onButtonsPlotTypeValueChanged(obj, origin, ~)
            buttons = obj.ButtonsPlotType;
            buttonPressed = origin;
            I = buttons == buttonPressed;
            set(buttons(~I), 'Value', false)
            set(buttons(~I), 'Enable', 'on')
            set(buttons(I), 'Value', true)
            set(buttons(I), 'Enable', 'off')
            
            plotType = buttonPressed.Tag;
            switch plotType
                case 'TyreCurves'
                    setupPlotCurves(obj)
                case 'FrictionEllipse'
                    setupPlotEllipse(obj)
            end
        end
        function onUiFigureSizeChanged(obj, ~, ~)
            parent = obj.Parent;
            while isa(parent, 'matlab.ui.container.GridLayout')
                parent = parent.Parent;
            end
            width = parent.Position(3);
            
            buttonsGrid = obj.ButtonsGrid;
            buttons = obj.ButtonsGrid.Children;
            buttonWidths = obj.ButtonsGridColumnWidthWithText;
            buttonWidths = buttonWidths(cellfun(@isnumeric, buttonWidths));
            minWidthButtonsWithText = sum([buttonWidths{:}]) ...
                + (numel(buttons)+2)*buttonsGrid.ColumnSpacing;
            removeTextFromButtons = width < minWidthButtonsWithText;
            if removeTextFromButtons
                set(buttons, 'Text', '')
                set(buttonsGrid, ...
                    'ColumnWidth', obj.ButtonsGridColumnWidthOnlyIcon);
            else
                texts = obj.ButtonsTexts;
                for i = 1:numel(buttons)
                    btn = buttons(i);
                    btn.Text = texts{i};
                end
                set(buttonsGrid, ...
                    'ColumnWidth', obj.ButtonsGridColumnWidthWithText);
            end
        end
    end
    methods(Access = protected)
        function setupPlotEllipse(obj)
            delete(obj.GridPlot)
            setupGridPlot(obj)
            obj.Plot = ui.TyrePlotFrictionEllipsePanel(obj.GridPlot);
            e = events.ModelChangedEventData(obj.Model);
            notify(obj.Plot, 'TyreModelChanged', e)
            e = events.TyreMeasurementsChanged(obj.Measurements);
            notify(obj.Plot, 'TyreDataChanged', e)
        end
        function setupPlotCurves(obj)
            delete(obj.GridPlot)
            setupGridPlot(obj)
            obj.Plot = ui.TyrePlotCurvesPanel(obj.GridPlot);
            e = events.ModelChangedEventData(obj.Model);
            notify(obj.Plot, 'TyreModelChanged', e)
            e = events.TyreMeasurementsChanged(obj.Measurements);
            notify(obj.Plot, 'TyreDataChanged', e)
        end
        function setupGrid(obj)
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {22,'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 0*ones(1,4), ...
                'Scrollable', false);
        end
        function setupGridPlot(obj)
            obj.GridPlot = uigridlayout(obj.Grid, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
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
                'Tag', 'TyreCurves', ...
                'Icon', 'plot_curves_icon.svg', ...
                'Value', true, ...
                'Enable', 'off');
            btn2 = uibutton(obj.ButtonsGrid, 'state', ...
                'Text', 'Friction Ellipse', ...
                'Tag', 'FrictionEllipse', ...
                'Icon', 'plot_friction_ellipse_icon.svg', ...
                'Value', false, ...
                'Enable', 'on');
            obj.ButtonsPlotType = [btn1 btn2];
            set(obj.ButtonsPlotType, ...
                'ValueChangedFcn', @obj.onButtonsPlotTypeValueChanged)
            
            obj.ShowSidebarStateButton = ...
                uibutton(obj.ButtonsGrid, 'state', ...
                'Icon', 'gears-solid.svg', ...
                'Text', 'Show Sidebar', ...
                'Value', true, ...
                'Tooltip', 'Toggles visibility of axes sidebar', ...
                'ValueChangedFcn', @obj.onShowSidebarStateButtonValueChanged);
            obj.ShowSidebarStateButton.Layout.Column = ...
                numel(obj.ButtonsGrid.ColumnWidth);
            
            btns = obj.ButtonsGrid.Children;
            obj.ButtonsTexts = {btns.Text};
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onModelChanged);
            addlistener(obj, 'TyreDataChanged', @obj.onDataChanged);
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            obj.Settings = settings.AppSettings();
            setupGrid(obj)
            setupButtons(obj)
            setupPlotCurves(obj)
            setupListeners(obj)
            set(obj, 'SizeChangedFcn', @obj.onUiFigureSizeChanged)
        end
        function update(obj)
            updateShowSideBarButton(obj)
        end
        function updateShowSideBarButton(obj)
            showSidebar = obj.Settings.View.TyreAnalysisPanel.ShowSidebar;
            set(obj.ShowSidebarStateButton, 'Value', showSidebar)
        end
    end
end
