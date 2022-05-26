classdef TyreMeasurementsPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREMEASUREMENTSPANEL
    
    events (HasCallbackProperty, NotifyAccess = protected)
        MeasurementDataImportRequested
        MeasurementDataClearRequested
        MeasurementDataExportRequested
    end
    
    events (NotifyAccess = public)
        MeasurementDataChanged
    end
    events (HasCallbackProperty, NotifyAccess = protected)
        PlotTyreMeasurementsRequested
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid            matlab.ui.container.GridLayout
        ButtonsGrid     matlab.ui.container.GridLayout
        Table           ui.TyreMeasurementsTable
        ImportButton    matlab.ui.control.Button
        ExportButton    matlab.ui.control.Button
        ClearButton     matlab.ui.control.Button
        PlotButton      matlab.ui.control.Button
    end
    properties (Access = protected)
        ButtonsGridColumnWidthWithText = [repmat({110}, 1, 4) {'1x'}];
        ButtonsGridColumnWidthOnlyIcon = [repmat({25}, 1, 4) {'1x'}];
        ButtonsTexts cell
    end
    
    methods (Access = private)
        function onImportMeasurementDialogRequested(obj, ~, ~)
            notify(obj, 'MeasurementDataImportRequested')
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
                [buttons(:).Text] = deal(texts{:});
                set(buttonsGrid, ...
                    'ColumnWidth', obj.ButtonsGridColumnWidthWithText);
            end
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 400 400];
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {'fit', '1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4));
            obj.ButtonsGrid = uigridlayout(obj.Grid, ...
                'RowHeight', {22}, ...
                'ColumnWidth', obj.ButtonsGridColumnWidthWithText, ...
                'ColumnSpacing', 10, ...
                'Padding', zeros(1,4));
            obj.ImportButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Import Data', ...
                'Icon', 'folder-open-solid.svg', ...
                'Tooltip', 'Import measurements using TYDEX parser', ...
                'ButtonPushedFcn', @obj.onImportMeasurementDialogRequested);
            obj.ExportButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Export Data', ...
                'Icon', 'floppy-disk-regular.svg', ...
                'Tooltip', 'Export measurements as TYDEX files', ...
                'ButtonPushedFcn', @obj.onMeasurementDataExportRequested);
            obj.ClearButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Clear Data', ...
                'Icon', 'trash-can-regular.svg', ...
                'Tooltip', 'Delete loaded measurements (does not delete files on disk)', ...
                'ButtonPushedFcn', @obj.onMeasurementDataClearRequested);
            obj.PlotButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Stacked Plot', ...
                'Icon', 'chart-line-solid.svg', ...
                'Tooltip', 'Visualize imported measurements in Stacked Plot', ...
                'ButtonPushedFcn', @obj.onPlotMeasurementRequested);
            btns = obj.ButtonsGrid.Children;
            obj.ButtonsTexts = {btns.Text};
            
            obj.Table = ui.TyreMeasurementsTable(obj.Grid);
            
            set(obj, 'SizeChangedFcn', @obj.onUiFigureSizeChanged)
            
            setupListeners(obj)
        end
        function setupListeners(obj)
            addlistener(obj, 'MeasurementDataChanged', ...
                @obj.onMeasurementDataChanged);
        end
        function update(obj)
        end
    end
end
