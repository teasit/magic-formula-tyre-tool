classdef TyreParametersTable < matlab.ui.componentcontainer.ComponentContainer
    
    properties (Access = public)
        Model MagicFormulaTyre
        FittedParameters magicformula.v61.Parameters = magicformula.v61.Parameters.empty
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
        TableViewSettingsChangedListener event.listener
        FitterSettingsChangedListener event.listener
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid            matlab.ui.container.GridLayout
        Table           matlab.ui.control.Table
    end
    
    properties (Transient, Access = private)
        % Indices of cells corresponding to search results
        SearchIndices (:,2)
        
        % Iterator of indices array (pressing ENTER adds to this)
        SearchIndicesIterator (1,1)
        
        SearchSeletedStyle matlab.ui.style.Style
        
        SearchMatchesStyle matlab.ui.style.Style
        
        FittedParamsStyle matlab.ui.style.Style
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        TyreModelEdited
        SearchResultsAvailable
    end
    
    events (NotifyAccess = public)
        TyreModelChanged
        TyreModelFitterFinished
        SearchTextChanged
        SearchPrevRequested
        SearchNextRequested
    end
    
    methods (Access = private)
        function removeStyleFromTable(obj, style)
            if isempty(style)
                return
            end
            tbl = obj.Table;
            bcolor = style.BackgroundColor;
            styles = tbl.StyleConfigurations.Style;
            bcolors = {styles.BackgroundColor};
            for i = 1:numel(styles)
                if isequal(bcolor, bcolors{i})
                    removeStyle(tbl, i)
                    return
                end
            end
        end
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
            
            data = obj.Table.Data;
            model = obj.Model;
            col = event.Indices(2);
            if col == obj.ColumnValue
                row = event.Indices(1);
                parameterValue = event.NewData;
                if ~isnan(str2double(parameterValue))
                    parameterValue = str2double(parameterValue);
                end
                parameterName = char(data(row, obj.ColumnParameter));
                model.Parameters.(parameterName).Value = parameterValue;
                notify(obj, 'TyreModelEdited')
            elseif col == obj.ColumnFixed
                row = event.Indices(1);
                parameterFixed = event.NewData;
                parameterFixed = logical(parameterFixed);
                parameterName = char(data(row, obj.ColumnParameter));
                model.Parameters.(parameterName).Fixed = parameterFixed;
            elseif col == obj.ColumnMin
                row = event.Indices(1);
                parameterMin = event.NewData;
                if ~isnan(str2double(parameterMin))
                    parameterMin = str2double(parameterMin);
                end
                parameterName = char(data(row, obj.ColumnParameter));
                model.Parameters.(parameterName).Min = parameterMin;
            elseif col == obj.ColumnMax
                row = event.Indices(1);
                parameterMax = event.NewData;
                if ~isnan(str2double(parameterMax))
                    parameterMax = str2double(parameterMax);
                end
                parameterName = char(data(row, obj.ColumnParameter));
                model.Parameters.(parameterName).Max = parameterMax;
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
        function onSearchTextChanged(obj, ~, event)
            tbl = obj.Table;
            text = event.Text;
            if isempty(text)
                removeStyleFromTable(obj, obj.SearchMatchesStyle)
                removeStyleFromTable(obj, obj.SearchSeletedStyle)
                obj.SearchMatchesStyle = matlab.ui.style.Style.empty;
                obj.SearchSeletedStyle = matlab.ui.style.Style.empty;
                return
            end
            
            data = tbl.Data;
            data = data(:, [obj.ColumnParameter obj.ColumnDescription]);
            
            I = contains(data, text, 'IgnoreCase', true);
            [rows,cols] = find(I);
            cols(cols==2) = obj.ColumnDescription;
            indices = [rows cols];
            
            if isempty(indices)
                i = 1;
                obj.SearchIndices = indices;
                obj.SearchIndicesIterator = i;
                e = events.SearchResultsAvailable(indices, i);
                notify(obj, 'SearchResultsAvailable', e)
                return
            end
            
            i = 1;
            row = indices(i,1);
            col = indices(i,2);
                
            styleMatches = uistyle('BackgroundColor', '#FFFFE0');
            removeStyleFromTable(obj, obj.SearchMatchesStyle)
            addStyle(tbl, styleMatches, 'cell', indices)
            obj.SearchMatchesStyle = styleMatches;
            
            styleSelected = uistyle('BackgroundColor', '#6495ED');
            removeStyleFromTable(obj, obj.SearchSeletedStyle)
            addStyle(tbl, styleSelected, 'cell', [row col])
            obj.SearchSeletedStyle = styleSelected;
            
            scroll(obj.Table, 'cell', [row, col])
            
            obj.SearchIndices = indices;
            obj.SearchIndicesIterator = i;
            
            e = events.SearchResultsAvailable(indices, i);
            notify(obj, 'SearchResultsAvailable', e)
        end
        function onSearchNextRequested(obj, ~, ~)
            tbl = obj.Table;
            
            indices = obj.SearchIndices;
            if isempty(indices)
                return
            end
            i = obj.SearchIndicesIterator;
            i = i + 1;
            if i > size(indices, 1)
                i = 1;
            end
            row = indices(i,1);
            col = indices(i,2);
            
            styleSelected = uistyle('BackgroundColor', '#6495ED');
            removeStyleFromTable(obj, obj.SearchSeletedStyle)
            addStyle(tbl, styleSelected, 'cell', [row col])
            obj.SearchSeletedStyle = styleSelected;
            
            scroll(tbl, 'cell', [row, col])
            
            obj.SearchIndicesIterator = i;
            
            e = events.SearchResultsAvailable(indices, i);
            notify(obj, 'SearchResultsAvailable', e)
        end
        function onSearchPrevRequested(obj, ~, ~)
            tbl = obj.Table;
            
            indices = obj.SearchIndices;
            if isempty(indices)
                return
            end
            i = obj.SearchIndicesIterator;
            i = i - 1;
            if i < 1
                i = size(indices, 1);
            end
            row = indices(i,1);
            col = indices(i,2);
            
            styleSelected = uistyle('BackgroundColor', '#6495ED');
            removeStyleFromTable(obj, obj.SearchSeletedStyle)
            addStyle(tbl, styleSelected, 'cell', [row col])
            obj.SearchSeletedStyle = styleSelected;
            
            scroll(tbl, 'cell', [row, col])
            
            obj.SearchIndicesIterator = i;
            
            e = events.SearchResultsAvailable(indices, i);
            notify(obj, 'SearchResultsAvailable', e)
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
            type = 'magicformula.ParameterFittable';
            isFittable = false(numParams, 1);
            for i = 1:numParams
                paramName = paramNames{i};
                param = params.(paramName);
                isFittable(i,1) = isa(param, type);
            end
            
            rows = numParams;
            cols = obj.NumberOfColumns;
            tableData = cell(rows,cols);
            table = obj.Table;
            
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
            
            paramsFitted = obj.FittedParameters;
            if isempty(paramsFitted)
                removeStyleFromTable(obj, obj.FittedParamsStyle)
            else
                darkgreen = '#006400';
                style = uistyle('FontColor', darkgreen);
                addStyle(table, style, 'column', obj.ColumnFittedValue)
                
                paramNames = properties(paramsFitted);
                paramNamesTbl = tableData(:, obj.ColumnParameter);
                
                for i = 1:numel(paramNames)
                    name = paramNames{i};
                    param = paramsFitted.(name);
                    if ~isa(param, 'magicformula.ParameterFittable')
                        continue
                    end
                    row = find(strcmp(paramNamesTbl, name));
                    tableData(row, obj.ColumnFittedValue) = {param.Value};
                end
            end
            
            s = obj.Settings;
            I_remove = false(numParams, 1);
            if s.View.TyreParametersTable.ShowOnlyFitModeParameters
                fitmodes = s.Fitter.FitModes;
                getFitParamNames = @magicformula.v61.Fitter.getFitParamNames;
                paramNamesFitModes = {};
                for i = 1:numel(fitmodes)
                    fitmode = fitmodes(i);
                    paramNamesFitModes = [paramNamesFitModes
                        getFitParamNames(fitmode)];
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
            obj.TableViewSettingsChangedListener = listener(...
                s.View.TyreParametersTable, ...
                'SettingsChanged', @(~,~) update(obj));
            obj.FitterSettingsChangedListener = listener(...
                s.Fitter, 'SettingsChanged', @(~,~) update(obj));
            addlistener(obj, 'SearchTextChanged', @obj.onSearchTextChanged);
            addlistener(obj, 'SearchPrevRequested', @obj.onSearchPrevRequested);
            addlistener(obj, 'SearchNextRequested', @obj.onSearchNextRequested);
        end
        function update(obj)
            updateTable(obj)
        end
    end
end
