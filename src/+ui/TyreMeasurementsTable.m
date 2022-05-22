classdef TyreMeasurementsTable < matlab.ui.componentcontainer.ComponentContainer
    %TYREMEASUREMENTSTABLE Shows measurements in tabular view.
    
    properties
        Measurements tydex.Measurement = tydex.Measurement.empty
        MeasurementsSelected tydex.Measurement = tydex.Measurement.empty
        FitModesFlagMap containers.Map
    end
    
    properties (Access = private)
        NumColumns {isinteger} = 4
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid            matlab.ui.container.GridLayout
        Table           matlab.ui.control.Table
    end
    
    methods (Access = public)
        function data = appendFitModesToTableData(obj, data, flagsMap)
            arguments
                obj
                data cell
                flagsMap containers.Map
            end
            
            if isempty(flagsMap)
                return
            end
            
            keys = flagsMap.keys();
            numMeasurements = numel(obj.Measurements);
            numKeys = numel(keys);
            
            fitmodesText = cell(numMeasurements, numKeys);
            for i = 1:numel(keys)
                key = keys{i};
                indices = flagsMap(key);
                fitmodesText(indices, i) = {key};
            end
            I = cellfun(@isempty, fitmodesText);
            fitmodesText(I) = {char.empty};
            fitmodesText = join(fitmodesText, ' ', 2);
            
            data(:,4) = fitmodesText;
        end
    end
    
    methods (Access = private)
        function onCellSelection(obj, source, event)
            measurements = obj.Measurements;
            if isempty(measurements)
                return
            end           
            indices = event.Indices;
            rows = unique(indices(:,1));
            measurementsSelected = measurements(rows);
            obj.MeasurementsSelected = measurementsSelected;
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 800 400];
            
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));
            
            obj.Table = uitable(obj.Grid, ...
                'ColumnName', {
                'Measurement ID'
                'Supplier'
                'Stationary (Constant) Variables'
                'Fit Modes'
                }, ... 
                'ColumnWidth', {110, 110, 550, 'auto'}, ...
                'ColumnEditable', logical([0 0 0 0]), ...
                'ColumnSortable', logical([1 1 1 1]), ...
                'CellSelectionCallback', @obj.onCellSelection);
        end
        function update(obj)
            measurements = obj.Measurements;            
            numMeasurements = numel(measurements);
            tableData = cell(numMeasurements, obj.NumColumns);
            
            for i = 1:numMeasurements
                msrmnt = measurements(i);
                meta = msrmnt.Metadata;
                measIdName = meta(strcmp({meta.Name}, 'MEASID')).Value;
                supplierName = meta(strcmp({meta.Name}, 'SUPPLIER')).Value;
                
                numConstants = numel({msrmnt.Constant.Name});
                strConstants = cell(numConstants,1);
                for j = 1:numConstants
                    unit = msrmnt.Constant(j).Unit;
                    value = msrmnt.Constant(j).Value;
                    if strcmp(unit, 'rad')
                        value = rad2deg(value);
                        unit = 'deg';
                    end
                    value = round(value);
                    name = msrmnt.Constant(j).Name;
                    str = sprintf('%s=%d%s', name, value, unit);
                    strConstants{j,1} = str;
                end
                constantNamesWithValues = strjoin(strConstants, ', ');
                
                tableData(i,:) = {
                    measIdName
                    supplierName
                    constantNamesWithValues
                    ''
                    };
            end
            
            flagsMap = obj.FitModesFlagMap;
            if ~isempty(flagsMap) && ~isempty(measurements)
                tableData = appendFitModesToTableData(obj, tableData, ...
                    flagsMap);
            end
            
            obj.Table.Data = tableData;
        end
    end
end
