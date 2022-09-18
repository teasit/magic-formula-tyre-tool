classdef TyrePlotCurvesPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREPLOTCURVESPANEL Plot X-Var sweeps with corresponding Y-Var.
    
    properties
        Model magicformula.v62.Model = magicformula.v62.Model.empty
        Measurements tydex.Measurement = tydex.Measurement.empty
    end
    properties (Access = private)
        SteadyStateNamesAll = {
            'LONGSLIP'
            'SLIPANGL'
            'INCLANGL'
            'INFLPRES'
            'FZW'}
        SteadyStateUnitsAll = {
            '1'
            'deg'
            'deg'
            'bar'
            'N'
            };
        LegendLabels = {};
        Settings settings.AppSettings
        ViewSettingsChangedListener event.listener
    end
    properties (Access = private, Transient, NonCopyable)
        MainGrid                    matlab.ui.container.GridLayout
        Axes                        matlab.ui.control.UIAxes
        SidePanel                   matlab.ui.container.Panel
        
        SidePanelGrid               matlab.ui.container.GridLayout
        PlotSettingsPanel           matlab.ui.container.Panel
        SteadyStateSettingsPanel    matlab.ui.container.Panel
        
        PlotSettingsPanelGrid       matlab.ui.container.GridLayout
        AutoRefreshStateButtonLabel matlab.ui.control.Label
        AutoRefreshStateButton      matlab.ui.control.StateButton
        HoldOnSettingLabel          matlab.ui.control.Label
        HoldOnSettingStateButton    matlab.ui.control.StateButton
        DataShowSettingLabel        matlab.ui.control.Label
        DataShowSettingStateButton  matlab.ui.control.StateButton
        ModelShowSettingLabel       matlab.ui.control.Label
        ModelShowSettingStateButton matlab.ui.control.StateButton
        ShowLegendStateButtonLabel  matlab.ui.control.Label
        ShowLegendStateButton       matlab.ui.control.StateButton
        XAxisSettingLabel           matlab.ui.control.Label
        XAxisSettingDropDown        matlab.ui.control.DropDown
        YAxisSettingLabel           matlab.ui.control.Label
        YAxisSettingDropDown        matlab.ui.control.DropDown
        XAxisRangeSelector          ui.NumericRangeSelector
        
        SteadyStateSettingsPanelGrid    matlab.ui.container.GridLayout
        SteadyStateSettingLabels        matlab.ui.control.Label
        SteadyStateSettingDropDowns     matlab.ui.control.DropDown
    end
    events (NotifyAccess = public)
        TyreModelChanged
        TyreDataChanged
    end
    methods (Access = private)
        function onModelChanged(obj, ~, event)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            obj.Model = event.Model;
            if ~isempty(obj.Model) || s.AutoRefresh
                updatePlot(obj)
            end
        end
        function onDataChanged(obj, ~, event)
            measurements = event.Measurements;
            obj.Measurements = measurements;
        end
        function onSettingsChanged(obj, source, event)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            tag = source.Tag;
            switch tag
                case {'AutoRefresh', 'DataShow', 'ModelShow'}
                    enable = event.Value;
                    s.(tag) = enable;
                case 'HoldOn'
                    enable = event.Value;
                    s.(tag) = enable;
                    return
                case {'XAxis', 'YAxis'}
                    axis = event.Value;
                    s.(tag) = axis;
                case 'LegendOn'
                    enable = event.Value;
                    s.(tag) = enable;
                    if enable
                        labels = obj.LegendLabels;
                        if ~isempty(labels)
                            legend(obj.Axes, labels, ...
                                'Location', 'southeast', ...
                                'Orientation', 'Horizontal', ...
                                'FontName', 'FixedWidth', ...
                                'NumColumns', 3)
                        end
                    else
                        legend(obj.Axes, 'off')
                    end
                    return
            end
            [names, values] = getSteadyStateUserSelection(obj);
            s.SteadyStateNamesSelected = names;
            s.SteadyStateValuesSelected = values;
            updateDropDowns(obj)
            updatePlot(obj)
        end
    end
    methods(Access = protected, Static)
        function units = getUnitsFromNames(names)
            if ischar(names)
                names = {names};
            end
            
            units = cell(1,numel(names));
            for i = 1:numel(names)
                switch names{i}
                    case 'LONGSLIP'
                        units{i} = '1';
                    case {'SLIPANGL', 'INCLANGL'}
                        units{i} = 'deg';
                    case 'INFLPRES'
                        units{i} = 'bar';
                    case {'FZW', 'FYW', 'FX'}
                        units{i} = 'N';
                end
            end
        end
    end
    methods(Access = private)
        function label = getLegendLabelFromNameValuePairs(obj, names, values)
            isRad = contains(names, {'INCLANGL', 'SLIPANGL'});
            isPascal = contains(names, 'INFLPRES');
            values(isRad) = cellfun(@rad2deg, values(isRad), ...
                'UniformOutput', false);
            values(isPascal) = cellfun(@(x)x*1E-5, values(isPascal), ...
                'UniformOutput', false);
            units = obj.getUnitsFromNames(names);
            values = cellfun(@(x)round(x,2), values, 'UniformOutput', false);
            valuesStr = cellfun(@num2str, values, 'UniformOutput', false);
            labelData = [names; values; units];
            lenLabel = max(cellfun(@numel, names));
            lenValue = max(cellfun(@numel, valuesStr)) + 3; % 3 = '.' + decimals
            label = sprintf(['\t\t%-' num2str(lenLabel) 's = %' num2str(lenValue) '.2f [%s]\n'], labelData{:});
        end
        function [names, values] = getSteadyStateUserSelection(obj)
            xAxisSetting = obj.XAxisSettingDropDown.Value;
            steadyStateNames = obj.XAxisSettingDropDown.Items;
            steadyStateValues = {obj.SteadyStateSettingDropDowns.Value};
            excludeIdx = strcmp(steadyStateNames, xAxisSetting);
            steadyStateNames(excludeIdx) = [];
            steadyStateValues(excludeIdx) = [];
            
            ischarIdx = cellfun(@ischar, steadyStateValues);
            steadyStateValues(ischarIdx) = cellfun(@str2double, ...
                steadyStateValues(ischarIdx), 'UniformOutput', false);
            isnanIdx = cellfun(@isnan, steadyStateValues);
            steadyStateValues(isnanIdx) = {0};
            isBarByUser = and(ischarIdx, ...
                contains(steadyStateNames, {'INFLPRES'}));
            isDegByUser = and(ischarIdx, ...
                contains(steadyStateNames, {'SLIPANGL', 'INCLANGL'}));
            steadyStateValues(isDegByUser) = cellfun(@deg2rad, ...
                steadyStateValues(isDegByUser), 'UniformOutput', false);
            steadyStateValues(isBarByUser) = cellfun(@(x)x*1E5, ...
                steadyStateValues(isBarByUser), 'UniformOutput', false);
            
            names = steadyStateNames;
            values = steadyStateValues;
        end
        function findSteadyStateValues(obj)
            % FINDSTEADYSTATEVALUES extracts all steady state values from
            % the loaded measurements. For example that in the testing data
            % three inclination angles were tested: 0, 2 and 4 degrees.
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            measurements = obj.Measurements;
            if isempty(measurements)
                mc = ?settings.TyrePlotCurvesPanelViewSettings;
                mp = mc.PropertyList;
                prop = findobj(mp, 'Name', 'SteadyStateValues');
                steadyStateValues = prop.DefaultValue;
            end
            
            steadyStateNamesAll = obj.SteadyStateNamesAll;
            steadyStateValues = cell(1, numel(steadyStateNamesAll));
            steadyStateValues(:) = {{}};
            
            for i = 1:numel(measurements)
                measurement = measurements(i);
                
                constantNames = {measurement.Constant.Name};
                constantValues = [measurement.Constant.Value];
                excludeIdx = contains(constantNames, {'FNOMIN', 'NOMPRES'});
                constantNames(excludeIdx) = [];
                
                for j = 1:numel(constantNames)
                    idx = strcmp(steadyStateNamesAll, constantNames{j});
                    steadyStateValues{idx}(end+1,1) = {constantValues(j)};
                end
            end
            
            for i = 1:size(steadyStateValues,2)
                vals = steadyStateValues{:,i};
                [~, idxUnique] = unique([vals{:}]);
                steadyStateValues{:,i} = vals(idxUnique);
            end
            
            s.SteadyStateValues = steadyStateValues;
        end
        function measurements = getMeasurementAtSelectedSteadyStates(obj)
            measurements = obj.Measurements;
            if isempty(measurements)
                return
            end
            
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            steadyStateNames = s.SteadyStateNamesSelected;
            steadyStateValues = s.SteadyStateValuesSelected;
            
            indices = false(size(measurements));
            for i = 1:numel(measurements)
                measurement = measurements(i);
                
                constantNames = {measurement.Constant.Name};
                excludeIdx = contains(constantNames, {'FNOMIN', 'NOMPRES'});
                constantNames(excludeIdx) = [];
                areSteadyState = contains(constantNames, steadyStateNames);
                
                if ~all(areSteadyState)
                    continue
                end
                
                numVars = numel(steadyStateNames);
                j = 1;
                while j <= numVars
                    var = steadyStateNames{j};
                    val = steadyStateValues{j};
                    isValid = measurement.(var) == val;
                    if ~isValid
                        break
                    end
                    j = j+1;
                end
                indices(i) = isValid;
            end
            
            measurements = measurements(indices);
        end
        function onXAxisRangeChanged(obj, ~, event)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            range = event.Range;
            xAxisLabel = obj.XAxisSettingDropDown.Value;
            switch xAxisLabel
                case 'LONGSLIP'
                    s.XAxisRangeLONGSLIP = range;
                case 'SLIPANGL'
                    s.XAxisRangeSLIPANGL = range;
                case 'INCLANGL'
                    s.XAxisRangeINCLANGL = range;
                case 'INFLPRES'
                    s.XAxisRangeINFLPRES = range;
                case 'FZW'
                    s.XAxisRangeFZW = range;
                otherwise
                    return
            end
            updatePlot(obj)
        end
    end
    methods(Access = protected)
        function updateSidebarState(obj)
            show = obj.Settings.View.TyreAnalysisPanel.ShowSidebar;
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
        function updatePlot(obj)
            ax = obj.Axes;
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            holdOn = s.HoldOn;
            if ~holdOn
                cla(ax)
            end
            
            model = obj.Model;
            measurements = obj.Measurements;
            
            showModel = obj.ModelShowSettingStateButton.Value;
            showData = obj.DataShowSettingStateButton.Value;
            
            plotModel = ~isempty(model) && showModel;
            plotData = ~isempty(measurements) && showData;
            
            xVar = obj.XAxisSettingDropDown.Value;
            yVar = obj.YAxisSettingDropDown.Value;
            
            hData = gobjects().empty(1,0);
            hModel = gobjects().empty(1,0);
            
            vars = s.SteadyStateNamesSelected;
            vals = s.SteadyStateValuesSelected;
            
            if plotModel
                switch xVar
                    case 'LONGSLIP'
                        range = s.XAxisRangeLONGSLIP;
                        LONGSLIP = linspace(range(1), range(2));
                        SLIPANGL = vals{strcmp(vars, 'SLIPANGL')};
                        INCLANGL = vals{strcmp(vars, 'INCLANGL')};
                        INFLPRES = vals{strcmp(vars, 'INFLPRES')};
                        FZW      = vals{strcmp(vars, 'FZW')};
                        xVal = LONGSLIP;
                    case 'SLIPANGL'
                        range = s.XAxisRangeSLIPANGL;
                        LONGSLIP = vals{strcmp(vars, 'LONGSLIP')};
                        SLIPANGL = deg2rad(linspace(range(1), range(2)));
                        INCLANGL = vals{strcmp(vars, 'INCLANGL')};
                        INFLPRES = vals{strcmp(vars, 'INFLPRES')};
                        FZW      = vals{strcmp(vars, 'FZW')};
                        xVal = rad2deg(SLIPANGL);
                    case 'INCLANGL'
                        range = s.XAxisRangeINCLANGL;
                        LONGSLIP = vals{strcmp(vars, 'LONGSLIP')};
                        SLIPANGL = vals{strcmp(vars, 'SLIPANGL')};
                        INCLANGL = deg2rad(linspace(range(1), range(2)));
                        INFLPRES = vals{strcmp(vars, 'INFLPRES')};
                        FZW      = vals{strcmp(vars, 'FZW')};
                        xVal = rad2deg(INCLANGL);
                    case 'INFLPRES'
                        pascal2bar = @(x) x*1E-5;
                        bar2pascal = @(x) x*1E+5;
                        range = bar2pascal(s.XAxisRangeINFLPRES);
                        LONGSLIP = vals{strcmp(vars, 'LONGSLIP')};
                        SLIPANGL = vals{strcmp(vars, 'SLIPANGL')};
                        INCLANGL = vals{strcmp(vars, 'INCLANGL')};
                        INFLPRES = linspace(range(1), range(2));
                        FZW      = vals{strcmp(vars, 'FZW')};
                        xVal = pascal2bar(INFLPRES);
                    case 'FZW'
                        range = s.XAxisRangeFZW;
                        LONGSLIP = vals{strcmp(vars, 'LONGSLIP')};
                        SLIPANGL = vals{strcmp(vars, 'SLIPANGL')};
                        INCLANGL = vals{strcmp(vars, 'INCLANGL')};
                        INFLPRES = vals{strcmp(vars, 'INFLPRES')};
                        FZW = linspace(range(1), range(2));
                        xVal = FZW;
                    otherwise
                        warning('Invalid x-axis variable!')
                        cla(ax)
                        return
                end
                
                params = obj.Model.Parameters;
                p = struct(params);
                [FX, FYW] = magicformula.v62.eval(p, SLIPANGL, LONGSLIP, ...
                    INCLANGL, INFLPRES, FZW, p.TYRESIDE);
                
                switch yVar
                    case 'FX'
                        yVal = FX;
                    case 'FYW'
                        yVal = FYW;
                    otherwise
                        warning('Invalid y-axis variable!')
                        cla(ax)
                        return
                end
                
                hModel = plot(ax, xVal, yVal, 'LineWidth', 2);
            end
            
            if plotData
                measurements = getMeasurementAtSelectedSteadyStates(obj);
                if isempty(measurements)
                    fig = ancestor(obj, 'figure');
                    message = 'No data available for steady-state settings.';
                    title = 'Tyre Analysis';
                    uialert(fig, message, title)
                end
                
                switch xVar
                    case 'LONGSLIP'
                        LONGSLIP = vertcat(measurements.LONGSLIP);
                        xVal = LONGSLIP;
                    case 'SLIPANGL'
                        SLIPANGL = vertcat(measurements.SLIPANGL);
                        xVal = rad2deg(SLIPANGL);
                    case 'INCLANGL'
                        INCLANGL = vertcat(measurements.INCLANGL);
                        xVal = rad2deg(INCLANGL);
                    case 'INFLPRES'
                        INFLPRES = vertcat(measurements.INFLPRES);
                        xVal = INFLPRES;
                    case 'FZW'
                        FZW = vertcat(measurements.FZW);
                        xVal = FZW;
                    otherwise
                        warning('Invalid x-axis variable!')
                        cla(ax)
                        return
                end
                
                switch yVar
                    case 'FX'
                        yVal = vertcat(measurements.FX);
                    case 'FYW'
                        yVal = vertcat(measurements.FYW);
                    otherwise
                        warning('Invalid y-axis variable!')
                        cla(ax)
                        return
                end
                
                hData = plot(ax, xVal, yVal, ...
                    'Marker', '.', ...
                    'LineStyle', 'none');
                if plotModel
                    color = hModel.Color;
                    set(hData, 'Color', color);
                end
            end
            
            xUnit = char(obj.getUnitsFromNames(xVar));
            yUnit = char(obj.getUnitsFromNames(yVar));
            
            xlabel(ax, sprintf('%s / %s', xVar, xUnit))
            ylabel(ax, sprintf('%s / %s', yVar, yUnit))
            
            if ~isempty(hModel) && ~isempty(hData)
                labels = {'Model:', 'Data:'};
            elseif ~isempty(hModel)
                labels = {'Model:'};
            elseif ~isempty(hData)
                labels = {'Data:'};
            else
                labels = {};
            end
            
            if isempty(labels)
                legend(ax, 'off');
                obj.LegendLabels = {};
            else
                for i = 1:numel(labels)
                    labelVals = getLegendLabelFromNameValuePairs(obj, ...
                        vars, vals);
                    labels{i} = sprintf('%s\n%s', labels{i}, labelVals);
                end
                if holdOn
                    labels = [obj.LegendLabels labels];
                end
                if ~obj.ShowLegendStateButton.Value
                    legend(ax, 'off');
                else
                    legend(labels, ...
                        'Location', 'southeast', ...
                        'Orientation', 'Horizontal', ...
                        'FontName', 'FixedWidth', ...
                        'NumColumns', 3)
                end
                obj.LegendLabels = labels;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % fixes a MATLAB issue with the axes toolbar disappearing.
            % see: mathworks.com/matlabcentral/answers/830253
            ax.Toolbar.HandleVisibility = 'off';
            ax.Toolbar.HandleVisibility = 'on';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        function updateDropDowns(obj)
            measurements = obj.Measurements;
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            if isempty(measurements)
                try
                    itemsSteadyState = s.SteadyStateValues;
                    notEmpty = all(~cellfun(@isempty, itemsSteadyState));
                    assert(notEmpty)
                catch
                    mc = ?settings.TyrePlotCurvesPanelViewSettings;
                    mp = mc.PropertyList;
                    prop = findobj(mp, 'Name', 'SteadyStateValues');
                    itemsSteadyState = prop.DefaultValue;
                end
            else
                findSteadyStateValues(obj)
                itemsSteadyState = s.SteadyStateValues;
            end
            
            pascal2bar = @(x) x*1E-5;
            names = obj.SteadyStateNamesAll;
            for i = 1:size(itemsSteadyState, 2)
                dd = obj.SteadyStateSettingDropDowns(i);
                items = itemsSteadyState{i};
                if iscell(items)
                    items = cell2mat(items);
                end
                name = names{i};
                if contains(name, {'INCLANGL', 'SLIPANGL'})
                    items = rad2deg(items);
                end
                if contains(name, 'INFLPRES')
                    items = pascal2bar(items);
                end
                
                itemsStr = num2str(items);
                itemsStr = cellstr(itemsStr);
                itemsStr = erase(itemsStr, ' ');
                itemsStr(isempty(itemsStr)) = '';
                dd.Items = itemsStr;
                dd.ItemsData = itemsSteadyState{i};
            end
            
            %Whatever variable is set for X-Axis, cannot be steady-state:
            xAxisSetting = obj.XAxisSettingDropDown.Value;
            I = strcmp(xAxisSetting, obj.SteadyStateNamesAll);
            enable = matlab.lang.OnOffSwitchState(~I);
            enable = num2cell(enable);
            [obj.SteadyStateSettingDropDowns(:).Enable] = deal(enable{:});
        end
        function updateXAxisRangeSelector(obj)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            xAxisLabel = obj.XAxisSettingDropDown.Value;
            switch xAxisLabel
                case 'LONGSLIP'
                    range = s.XAxisRangeLONGSLIP;
                    limits = [-1 1];
                    unit = '1';
                case 'SLIPANGL'
                    range = s.XAxisRangeSLIPANGL;
                    limits = [-90 90];
                    unit = 'deg';
                case 'INCLANGL'
                    range = s.XAxisRangeINCLANGL;
                    limits = [-90 90];
                    unit = 'deg';
                case 'INFLPRES'
                    range = s.XAxisRangeINFLPRES;
                    limits = [0 10];
                    unit = 'bar';
                case 'FZW'
                    range = s.XAxisRangeFZW;
                    limits = [0 1E5];
                    unit = 'N';
                otherwise
                    return
            end
            obj.XAxisRangeSelector.RangeLimits = limits;
            obj.XAxisRangeSelector.Range = range;
            obj.XAxisRangeSelector.Unit = unit;
        end
        function updatePlotSettings(obj)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            if isempty(obj.Model)
                set(obj.ModelShowSettingStateButton, 'Enable', 'off')
            else
                set(obj.ModelShowSettingStateButton, 'Enable', 'on')
            end
            
            if isempty(obj.Measurements)
                set(obj.DataShowSettingStateButton, 'Enable', 'off')
            else
                set(obj.DataShowSettingStateButton, 'Enable', 'on')
            end
            
            set(obj.AutoRefreshStateButton, 'Value', s.AutoRefresh)
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
        function setupPlotSettingsPanel(obj)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            
            grid = uigridlayout(obj.PlotSettingsPanel, ...
                'RowHeight', repmat({'fit'}, 9, 1), ...
                'ColumnWidth', {'fit', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 10*ones(1,4), ...
                'Scrollable', false);
            obj.PlotSettingsPanelGrid = grid;
            
            obj.AutoRefreshStateButtonLabel = uilabel(grid, ...
                'Text', 'Refresh');
            obj.AutoRefreshStateButton = uibutton(grid, 'state', ...
                'Text', 'Auto', ...
                'Value', s.AutoRefresh, ...
                'Tag', 'AutoRefresh', ...
                'Tooltip', 'Plot will update on new model changes.', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            
            obj.ShowLegendStateButtonLabel = uilabel(grid, 'Text', 'Legend');
            obj.ShowLegendStateButton = uibutton(grid, 'state', ...
                'Text', 'On', ...
                'Value', s.LegendOn, ...
                'Tag', 'LegendOn', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            
            obj.HoldOnSettingLabel = uilabel(grid, 'Text', 'Hold');
            obj.HoldOnSettingStateButton = uibutton(grid, 'state', ...
                'Value', s.HoldOn, ...
                'Text', 'On', ...
                'ValueChangedFcn', @obj.onSettingsChanged, ...
                'Tag', 'HoldOn');
            
            obj.DataShowSettingLabel = uilabel(grid, 'Text', 'Data');
            obj.DataShowSettingStateButton = uibutton(grid, 'state', ...
                'Text', 'Show', ...
                'Value', s.DataShow, ...
                'ValueChangedFcn', @obj.onSettingsChanged, ...
                'Tag', 'DataShow');
            
            obj.ModelShowSettingLabel = uilabel(grid, 'Text', 'Model');
            obj.ModelShowSettingStateButton = uibutton(grid, 'state', ...
                'Value', s.ModelShow, ...
                'Text', 'Show', ...
                'ValueChangedFcn', @obj.onSettingsChanged, ...
                'Tag', 'ModelShow');
            
            obj.XAxisSettingLabel = uilabel(grid, ...
                'Text', 'X-Axis', ...
                'Tag', 'XAxis');
            obj.XAxisSettingDropDown = uidropdown(grid, ...
                'Items', obj.SteadyStateNamesAll, ...
                'Value', s.XAxis, ...
                'Tag', 'XAxis', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            
            obj.YAxisSettingLabel = uilabel(grid, ...
                'Text', 'Y-Axis');
            obj.YAxisSettingDropDown = uidropdown(grid, ...
                'Items', {'FX','FYW'}, ...
                'Tag', 'YAxis', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            
            uilabel(grid, 'Text', 'X-Range');
            selector = ui.NumericRangeSelector(grid, ...
                'RangeChangedFcn', @obj.onXAxisRangeChanged);
            uilabel(grid, 'Text', char.empty);  % to keep grid flow
            selector.Layout.Row = [0 1] + selector.Layout.Row;
            obj.XAxisRangeSelector = selector;
        end
        function setupSteadyStateSettingsPanel(obj)
            s = obj.Settings.View.TyreAnalysisPanel.TyrePlotCurvesPanel;
            grid = uigridlayout(obj.SteadyStateSettingsPanel, ...
                'RowHeight', repmat({'fit'}, 1, 6), ...
                'ColumnWidth', {'fit', 'fit', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 10*ones(1,4), ...
                'Scrollable', false);
            
            names = obj.SteadyStateNamesAll;
            units = obj.SteadyStateUnitsAll;
            units = cellfun(@(x) sprintf('[%s]', x), units, ...
                'UniformOutput', false);
            
            for i = 1:numel(names)
                name = names{i};
                obj.SteadyStateSettingLabels(i) = uilabel(grid, ...
                    'Text', name);
                obj.SteadyStateSettingDropDowns(i) = uidropdown(grid, ...
                    'Editable', true, ...
                    'ValueChangedFcn', @obj.onSettingsChanged);
                uilabel(grid, 'Text', units{i}, ...
                    'HorizontalAlignment', 'center');
            end
            
            obj.SteadyStateSettingsPanelGrid = grid;
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
            
            obj.PlotSettingsPanel = uipanel(obj.SidePanelGrid, ...
                'Title', 'Plot Settings', ...
                'BorderType', 'none');
            
            obj.SteadyStateSettingsPanel = uipanel(obj.SidePanelGrid, ...
                'Title', 'Steady-State Settings', ...
                'BorderType', 'none');
        end
        function setupAxes(obj)
            ax = uiaxes(obj.MainGrid);
            ax.Title.String = '';
            xlabel(ax, 'LONGSLIP / 1')
            ylabel(ax, 'FX / N')
            grid(ax, 'on')
            hold(ax, 'on')
            obj.Axes = ax;
            ax.Layout.Column = 1;
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onModelChanged);
            addlistener(obj, 'TyreDataChanged', @obj.onDataChanged);
            obj.ViewSettingsChangedListener = listener(...
                obj.Settings.View.TyreAnalysisPanel, 'SettingsChanged', ...
                @(~,~) obj.update());
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            obj.Settings = settings.AppSettings();
            setupMainGrid(obj)
            setupAxes(obj)
            setupSidePanel(obj)
            setupPlotSettingsPanel(obj)
            setupSteadyStateSettingsPanel(obj)
            setupListeners(obj)
        end
        function update(obj)
            updateSidebarState(obj)
            updatePlotSettings(obj)
            updateDropDowns(obj)
            updateXAxisRangeSelector(obj)
        end
    end
end
