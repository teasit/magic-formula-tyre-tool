classdef TyreParametersTable < matlab.ui.componentcontainer.ComponentContainer
    
    properties (Access = public)
        Model mftyre.v62.Model
        FittedParameters mftyre.v62.Parameters = mftyre.v62.Parameters.empty
    end
    
    properties (Access = private, Constant)
        NumberOfColumns = 7
        ColumnParameter = 1
        ColumnFixed = 2
        ColumnValue = 3
        ColumnFittedValue = 4
        ColumnMin = 5
        ColumnMax = 6
        ColumnDescription = 7
    end
    
    properties (Access = private)
        Settings settings.AppSettings
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid    matlab.ui.container.GridLayout
        Table   matlab.ui.control.Table
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        TyreModelEdited
    end
    
    events (NotifyAccess = public)
        TyreModelChanged
        TyreModelFitterFinished
    end
    
    methods (Access = private)
        function onCellEdit(obj, source, event)
            prevData = event.PreviousData;
            
            cellAcceptsNoUserInput = strcmp(prevData, '-');
            if cellAcceptsNoUserInput
                tbl = source;
                row = event.Indices(1);
                col = event.Indices(2);
                tbl.Data{row,col} = prevData;
                return
            end
            
            col = event.Indices(2);
            if col == obj.ColumnValue
                row = event.Indices(1);
                parameterValue = event.NewData;
                if ~isnan(str2double(parameterValue))
                    parameterValue = str2double(parameterValue);
                end
                parameterName = char(obj.Table.Data(...
                    row, obj.ColumnParameter));
                obj.Model.Parameters.(parameterName).Value = parameterValue;
                notify(obj, 'TyreModelEdited')
            elseif col == obj.ColumnFixed
                row = event.Indices(1);
                parameterFixed = event.NewData;
                parameterFixed = logical(parameterFixed);
                parameterName = char(obj.Table.Data(...
                    row, obj.ColumnParameter));
                obj.Model.Parameters.(parameterName).Fixed = parameterFixed;
            elseif col == obj.ColumnMin
                row = event.Indices(1);
                parameterMin = event.NewData;
                if ~isnan(str2double(parameterMin))
                    parameterMin = str2double(parameterMin);
                end
                parameterName = char(obj.Table.Data(...
                    row, obj.ColumnParameter));
                obj.Model.Parameters.(parameterName).Min = parameterMin;
            elseif col == obj.ColumnMax
                row = event.Indices(1);
                parameterMax = event.NewData;
                if ~isnan(str2double(parameterMax))
                    parameterMax = str2double(parameterMax);
                end
                parameterName = char(obj.Table.Data(...
                    row, obj.ColumnParameter));
                obj.Model.Parameters.(parameterName).Max = parameterMax;
            end
        end
        function onTyreModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
        end
        function onTyreModelFitterFinished(obj, ~, event)
            paramsFit = event.ParametersFitted;
            obj.FittedParameters = paramsFit;
        end
    end
    
    methods (Access = protected)
        function updateTable(obj)
            model = obj.Model;
            if isempty(model)
                obj.Table.Data = [];
                return
            end
            
            params = model.Parameters;
            paramNames = fieldnames(params);
            numParams = numel(paramNames);
            type = 'mftyre.v62.ParameterFittable';
            isFittable = false(numParams, 1); 
            for i = 1:numParams
                paramName = paramNames{i};
                param = params.(paramName);
                isFittable(i,1) = isa(param, type);
            end
            
            rows = numParams;
            cols = obj.NumberOfColumns;
            tableData = cell(rows,cols);

            for i = 1:rows
                paramName = paramNames{i};
                paramObj = params.(paramName);
                paramValue = paramObj.Value;
                if isFittable(i,1)
                    paramMin = paramObj.Min;
                    paramMax = paramObj.Max;
                    paramFixed = paramObj.Fixed;
                    paramFittedValue = 0;
                else
                    paramMin = '-';
                    paramMax = '-';
                    paramFixed = '-';
                    paramFittedValue = '-';
                end
                paramDescription = char(paramObj.Description);
                if isempty(paramDescription)
                    paramDescription = ' ';
                end
                
                tableData(i,:) = {
                    paramName
                    paramFixed
                    paramValue
                    paramFittedValue
                    paramMin
                    paramMax
                    paramDescription
                    };
            end
            
            s = obj.Settings;
            I_remove = false(numParams, 1);
            if s.View.TyreParametersTable.ShowOnlyFitModeParameters
                fitmodes = s.Fitter.FitModes;
                paramNamesFitModes = {};
                for i = 1:numel(fitmodes)
                    fitmode = fitmodes(i);
                    paramNamesFitModes = [paramNamesFitModes
                        mftyre.v62.getFitParamNames(fitmode)];
                end
                isForFitmodes = contains(paramNames, paramNamesFitModes);
                I_remove = I_remove | ~isForFitmodes;
            end
            if ~s.View.TyreParametersTable.ShowFittableParameters
                I_remove = I_remove | isFittable;
            end
            if ~s.View.TyreParametersTable.ShowNonFittableParameters
                I_remove = I_remove | ~isFittable;
            end
            
            tableData(I_remove, :) = [];
            obj.Table.Data = tableData;
        end
        function updateFittedParams(obj)
            table = obj.Table;
            colParameter = obj.ColumnParameter;
            colFittedValue = obj.ColumnFittedValue;
            
            params = obj.FittedParameters;
            if isempty(params)
                style = uistyle();
                addStyle(table, style, 'column', colFittedValue)
                return
            else
                darkgreen = '#006400';
                style = uistyle('FontColor', darkgreen);
                addStyle(table, style, 'column', colFittedValue)
            end
            
            paramNames = properties(params);
            paramNamesTbl = table.Data(:,colParameter);
            
            tableData = table.Data;
            for i = 1:numel(paramNames)
                name = paramNames{i};
                param = params.(name);
                if ~isa(param, 'mftyre.v62.ParameterFittable')
                    continue
                end
                row = find(strcmp(paramNamesTbl, name));
                tableData(row, colFittedValue) = {param.Value};
            end
            table.Data = tableData;
        end
    end

    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 800 400];  % for testing
            
            obj.Settings = settings.AppSettings();
            
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', 0*ones(1,4));
            
            obj.Table = uitable(obj.Grid, ...
                'ColumnName', {'Parameter', 'Fixed', 'Value', ...
                'Fitted Value', 'Min', 'Max', 'Description'}, ...
                'RowName', {}, ...
                'ColumnWidth', {120, 22, 100, 100, 70, 70, 'auto'}, ...
                'ColumnEditable', logical([0, 1, 1, 0, 1, 1, 0]), ...
                'ColumnSortable', logical([1, 1, 1, 1, 0, 0, 0]), ...
                'CellEditCallback', @obj.onCellEdit);
            
            setupListeners(obj)
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onTyreModelChanged);
            addlistener(obj, 'TyreModelFitterFinished', ...
                @obj.onTyreModelFitterFinished);
            s = obj.Settings;
            addlistener(s.View.TyreParametersTable, ...
                'SettingsChanged', @(~,~) update(obj));
            addlistener(s.Fitter, 'SettingsChanged', @(~,~) update(obj));
        end
        function update(obj)
            updateTable(obj)
            updateFittedParams(obj)
        end
    end
end
