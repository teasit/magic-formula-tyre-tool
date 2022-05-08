classdef TyreModelPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREMODELPANEL UI for viewing and fitting MFTyre models.
    
    properties
        Model mftyre.Model = mftyre.v62.Model.empty
        Fitter mftyre.v62.Fitter = mftyre.v62.Fitter.empty
    end
    properties (Access = private)
        UiChart ui.TyreModelPanelChart
    end
    properties (Access = ?ui.TyreModelPanelChart, Transient, NonCopyable)
        MainGrid                matlab.ui.container.GridLayout
        TyreParametersTable     ui.TyreParametersTable
    end
    properties (Access = ?ui.TyreModelPanelChart, Transient, NonCopyable)
        ButtonsGrid             matlab.ui.container.GridLayout
        NewModelButton          matlab.ui.control.Button
        LoadModelButton         matlab.ui.control.Button
        SaveModelButton         matlab.ui.control.Button
        ResetModelButton        matlab.ui.control.Button
        ApplyFittedButton       matlab.ui.control.Button
        ClearModelButton        matlab.ui.control.Button
        StructToMatButton       matlab.ui.control.Button
        FitterStateButton       matlab.ui.control.StateButton
    end
    properties (Access = ?ui.TyreModelPanelChart, Transient, NonCopyable)
        SidePanelGrid matlab.ui.container.GridLayout
        FitterPanel ui.TyreFitterPanel
    end
    events (HasCallbackProperty, NotifyAccess = protected)
        FitterSettingsChanged
        FitterStartRequested
        FitterFittingModesChanged
        TyreModelClearRequested
        TyreModelNewRequested
        TyreModelSaveRequested
        TyreModelResetRequested
        TyreModelApplyFittedRequested
        TyreModelStructToMatRequested
        LoadTyreModelDialogReqested
    end
    events (NotifyAccess = public)
        TyreModelChanged
        TyreModelFitterFinished
        ViewSettingsChanged
    end
    methods(Access = private)
        function onSaveModelRequested(obj, ~, ~)
            notify(obj, 'TyreModelSaveRequested')
        end
        function onClearModelReq(obj, ~, ~)
            notify(obj, 'TyreModelClearRequested')
        end
        function onTyreModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
            evntdata = events.ModelChangedEventData(model);
            notify(obj.TyreParametersTable, 'TyreModelChanged', evntdata)
        end
        function onNewModelRequested(obj, ~, ~)
            notify(obj, 'TyreModelNewRequested')
        end
        function onLoadModelRequested(obj, ~, ~)
            notify(obj, 'LoadTyreModelDialogReqested')
        end
        function onResetModelRequested(obj, ~, ~)
            notify(obj, 'TyreModelResetRequested')
        end
        function onFitterStateButtonChanged(obj, ~, event)
            if event.Value
                obj.UiChart.ShowFitterPanel;
            else
                obj.UiChart.HideFitterPanel;
            end
        end
        function onFitterSettingsChanged(obj, ~, event)
            arguments
                obj
                ~
                event events.FitterSettingsChangedEventData
            end
            obj.Fitter.Options = event.Settings;
        end
        function onFitterFittingModesChanged(obj, ~, event)
            modes = event.FitModes;
            obj.TyreParametersTable.FitModes = modes;
            evntdata = events.FittingModesChangedEventData(modes);
            notify(obj, 'FitterFittingModesChanged', evntdata)
        end
        function onTyreModelFitterFinished(obj, ~, event)
            paramsFit = event.ParametersFitted;
            e = events.TyreModelFitterFinished(paramsFit);
            notify(obj.TyreParametersTable, 'TyreModelFitterFinished', e)
            obj.UiChart.TyreModelFitted()
        end
        function onViewSettingsChanged(obj, ~, event)
            settings = event.Settings;
            table = obj.TyreParametersTable;
            table.ViewSettings = settings.TyreParametersTableViewSettings;
        end
        function onFitterStartRequested(obj, ~, ~)
            notify(obj, 'FitterStartRequested')
        end
        function onApplyFittedRequested(obj, ~, ~)
            notify(obj, 'TyreModelApplyFittedRequested')
        end
        function onStructToMatRequested(obj, ~, ~)
            notify(obj, 'TyreModelStructToMatRequested')
        end
    end
    methods (Access = protected)
        function setupButtons(obj)
            obj.ButtonsGrid = uigridlayout(obj.MainGrid, ...
                'RowHeight', {22}, ...
                'ColumnWidth', [repmat({110}, 1, 7) {'1x' 110}], ...
                'ColumnSpacing', 10, ...
                'Padding', zeros(1,4));
            obj.ButtonsGrid.Layout.Column = [1 2];
            
            obj.NewModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'New Model', ...
                'Tooltip', 'Creates new tyre model with default values.', ...
                'Icon', 'file-circle-plus-solid.svg', ...
                'ButtonPushedFcn', @obj.onNewModelRequested);
            
            obj.LoadModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Load Model', ...
                'Tooltip', 'Loads tyre model from file.', ...
                'Icon', 'folder-open-solid.svg', ...
                'ButtonPushedFcn', @obj.onLoadModelRequested);
            
            obj.SaveModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Save Model', ...
                'Tooltip', 'Saves tyre model to file.', ...
                'Icon', 'floppy-disk-regular.svg', ...
                'Enable', false, ...
                'ButtonPushedFcn', @obj.onSaveModelRequested);
            
            obj.ResetModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Reset Model', ...
                'Tooltip', 'Reverts tyre model state to saved state.', ...
                'Icon', 'rotate-left-solid.svg', ...
                'Enable', false, ...
                'ButtonPushedFcn', @obj.onResetModelRequested);
            
            obj.ApplyFittedButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Apply Fitted', ...
                'Tooltip', 'Applies fitted parameters to model.', ...
                'Icon', 'copy-solid.svg', ...
                'Enable', false, ...
                'ButtonPushedFcn', @obj.onApplyFittedRequested);
            
            obj.StructToMatButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Struct to .mat', ...
                'Tooltip', 'Exports model parameters as struct to .mat file.', ...
                'Icon', 'file-export-solid.svg', ...
                'Enable', false, ...
                'ButtonPushedFcn', @obj.onStructToMatRequested);
            
            obj.ClearModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'Clear Model', ...
                'Tooltip', 'Deletes currently loaded tyre model.', ...
                'Icon', 'trash-can-regular.svg', ...
                'Enable', false, ...
                'ButtonPushedFcn', @obj.onClearModelReq);
            
            obj.FitterStateButton = uibutton(obj.ButtonsGrid, 'state', ...
                'Text', 'Show Fitter', ...
                'Tooltip', 'Shows/Hides fitter panel.', ...
                'Icon', 'gears-solid.svg', ...
                'Enable', false, ...
                'ValueChangedFcn', @obj.onFitterStateButtonChanged);
            obj.FitterStateButton.Layout.Column = ...
                numel(obj.ButtonsGrid.ColumnWidth);
        end
        function setupTyreParametersTable(obj)
            obj.TyreParametersTable = ui.TyreParametersTable(obj.MainGrid);
            obj.TyreParametersTable.Layout.Row = 2;
            obj.TyreParametersTable.Layout.Column = [1 2];
        end
        function setupMainGrid(obj)
            obj.MainGrid = uigridlayout(obj);
            obj.MainGrid.RowHeight = {22,'1x'};
            obj.MainGrid.ColumnWidth = {'1x', 'fit'};
            obj.MainGrid.ColumnSpacing = 10;
            obj.MainGrid.Padding = 10*ones(1,4);
            obj.MainGrid.Scrollable = false;
        end
        function setupSidePanel(obj)
            obj.SidePanelGrid = uigridlayout(obj.MainGrid, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'fit'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4), ...
                'Scrollable', true, ...
                'Visible', false);
            obj.SidePanelGrid.Layout.Row = 2;
            obj.SidePanelGrid.Layout.Column = 2;
            
            obj.FitterPanel = ui.TyreFitterPanel(obj.SidePanelGrid, ...
                'FitterSolverSettingsChangedFcn', ...
                @obj.onFitterSettingsChanged, ...
                'FitterFittingModesChangedFcn', ...
                @obj.onFitterFittingModesChanged, ...
                'FitterStartRequestedFcn', ...
                @obj.onFitterStartRequested);
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onTyreModelChanged);
            addlistener(obj, 'TyreModelFitterFinished', ...
                @obj.onTyreModelFitterFinished);
            addlistener(obj, 'ViewSettingsChanged', ...
                @obj.onViewSettingsChanged);
        end
    end
    methods (Access = protected)
        function setup(obj)
            setupMainGrid(obj)
            setupButtons(obj)
            setupTyreParametersTable(obj)
            setupSidePanel(obj)
            setupListeners(obj)
            obj.UiChart = ui.TyreModelPanelChart('obj', obj);
        end
        function update(obj)
            chart = obj.UiChart;
            if ~isempty(obj.Model)
                chart.TyreModelLoaded()
            else
                chart.TyreModelCleared()
            end
        end
    end
end
