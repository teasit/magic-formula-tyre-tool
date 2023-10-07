classdef TyreDataPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREMEASUREMENTSPANEL
    
    events (HasCallbackProperty, NotifyAccess = protected)
        MeasurementDataImportRequested
        MeasurementDataClearRequested
        MeasurementDataExportRequested
        MeasurementDataSelectionChanged
        PlotTyreMeasurementsRequested
    end
    
    events (NotifyAccess = public)
        MeasurementDataChanged
        MeasurementDataImportFinished
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridMain        matlab.ui.container.GridLayout
        GridCentral     matlab.ui.container.GridLayout
        GridSidebar     matlab.ui.container.GridLayout
        GridButtons     matlab.ui.container.GridLayout
        Table           ui.TyreDataTable
        ImportButton    matlab.ui.control.Button
        ExportButton    matlab.ui.control.Button
        ClearButton     matlab.ui.control.Button
        PlotButton      matlab.ui.control.Button
        Sidebar         ui.TyreDataImportPanel
    end
    properties (Access = protected)
        GridButtonsColumnWidthWithText = [repmat({...
            settings.LayoutSettings().DefaultButtonWidthTextIcon...
            }, 1, 3) {'1x'}];
        GridButtonsColumnWidthOnlyIcon = [repmat({...
            settings.LayoutSettings().DefaultButtonWidthOnlyIcon...
            }, 1, 3) {'1x'}];
        ButtonsTexts cell
    end
    
    methods (Access = private)
        function onDataImportRequested(obj, ~, event)
            notify(obj, 'MeasurementDataImportRequested', event);
        end
        function onMeasurementDataClearRequested(obj, ~, ~)
            notify(obj, 'MeasurementDataClearRequested')
        end
        function onMeasurementDataChanged(obj, ~, event)
            measurements = event.Measurements;
            flags = event.FitModeFlags;
            obj.Table.Measurements = measurements;
            obj.Table.FitModesFlagMap = flags;
        end
        function onMeasurementDataExportRequested(obj, ~, ~)
            notify(obj, 'MeasurementDataExportRequested')
        end
        function onPlotMeasurementRequested(obj, ~, ~)
            measurements = obj.Table.MeasurementsSelected;
            e = events.PlotTyreMeasurementsRequested(measurements);
            notify(obj, 'PlotTyreMeasurementsRequested', e)
        end
        function onMeasurementSelectionChanged(obj, ~, event)
            measurements = event.Measurements;
            I = event.Indices;
            e = events.MeasurementSelectionChanged(measurements, I);
            notify(obj, 'MeasurementDataSelectionChanged', e)            
        end
        function onMeasurementDataImportFinished(obj, ~, ~)
            notify(obj.Sidebar, 'DataImportFinished')
        end
        function onUiFigureSizeChanged(obj, ~, ~)
            parent = obj.Parent;
            while isa(parent, 'matlab.ui.container.GridLayout')
                parent = parent.Parent;
            end
            width = parent.Position(3);
            
            g = obj.GridButtons;
            buttons = obj.GridButtons.Children;
            buttonWidths = obj.GridButtonsColumnWidthWithText;
            buttonWidths = buttonWidths(cellfun(@isnumeric, buttonWidths));
            minWidthButtonsWithText = sum([buttonWidths{:}]) ...
                + (numel(buttons)+2)*g.ColumnSpacing;
            removeTextFromButtons = width < minWidthButtonsWithText;
            if removeTextFromButtons
                set(buttons, 'Text', '')
                set(g, ...
                    'ColumnWidth', obj.GridButtonsColumnWidthOnlyIcon);
            else
                texts = obj.ButtonsTexts;
                [buttons(:).Text] = deal(texts{:});
                set(g, 'ColumnWidth', obj.GridButtonsColumnWidthWithText);
            end
        end
    end
    
    methods (Access = protected)
        function setupSidebar(obj)
            s = settings.LayoutSettings();
            obj.GridSidebar = uigridlayout(obj.GridCentral, ...
                'RowHeight', {'fit'}, ...
                'ColumnWidth', {s.DefaultSidebarWidth}, ...
                'ColumnSpacing', 0, ...
                'Padding', [0 0 0 0], ...
                'Scrollable', true, ...
                'Visible', true);
            
            obj.Sidebar = ui.TyreDataImportPanel(obj.GridSidebar, ...
                'DataImportRequestedFcn', @obj.onDataImportRequested);
        end
        function setup(obj)
            s = settings.LayoutSettings();
            % Position only used for standalone-testing.
            obj.Position = [0 0 400 400];
            obj.GridMain = uigridlayout(obj, ...
                'RowHeight', {'fit','1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4));
            obj.GridButtons = uigridlayout(obj.GridMain, ...
                'RowHeight', {s.DefaultButtonHeight}, ...
                'ColumnWidth', obj.GridButtonsColumnWidthWithText, ...
                'ColumnSpacing', s.DefaultColumnSpacing, ...
                'Padding', zeros(1,4));
            obj.GridCentral = uigridlayout(obj.GridMain, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x','fit'}, ...
                'ColumnSpacing', s.DefaultColumnSpacing, ...
                'Padding', zeros(1,4));
            obj.ClearButton = uibutton(obj.GridButtons, ...
                'Text', 'Clear Data', ...
                'Icon', 'trash-can-regular.svg', ...
                'Tooltip', 'Delete loaded measurements (does not delete files on disk)', ...
                'ButtonPushedFcn', @obj.onMeasurementDataClearRequested);
            obj.ExportButton = uibutton(obj.GridButtons, ...
                'Text', 'Export Data', ...
                'Icon', 'floppy-disk-regular.svg', ...
                'Tooltip', 'Export measurements as TYDEX files', ...
                'ButtonPushedFcn', @obj.onMeasurementDataExportRequested);
            obj.PlotButton = uibutton(obj.GridButtons, ...
                'Text', 'Stacked Plot', ...
                'Icon', 'chart-line-solid.svg', ...
                'Tooltip', 'Visualize imported measurements in Stacked Plot', ...
                'ButtonPushedFcn', @obj.onPlotMeasurementRequested);
            btns = obj.GridButtons.Children;
            obj.ButtonsTexts = {btns.Text};
            
            obj.Table = ui.TyreDataTable(obj.GridCentral, ...
                'MeasurementSelectionChangedFcn', ...
                @obj.onMeasurementSelectionChanged);

            set(obj, 'SizeChangedFcn', @obj.onUiFigureSizeChanged)

            setupSidebar(obj)
            setupListeners(obj)
        end
        function setupListeners(obj)
            addlistener(obj, 'MeasurementDataChanged', ...
                @obj.onMeasurementDataChanged);
            addlistener(obj, 'MeasurementDataImportFinished', ...
                @obj.onMeasurementDataImportFinished);
        end
        function update(obj)
        end
    end
end
