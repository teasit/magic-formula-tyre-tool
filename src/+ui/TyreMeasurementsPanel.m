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
                'ColumnWidth', [repmat({110}, 1, 4) {'1x'}], ...
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
            obj.Table = ui.TyreMeasurementsTable(obj.Grid);
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
