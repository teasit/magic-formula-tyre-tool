classdef TyreModelPanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREMODELPANEL UI for viewing and fitting tyre models.
    
    properties
        Model MagicFormulaTyre = MagicFormulaTyre.empty
        Fitter magicformula.v61.Fitter = magicformula.v61.Fitter.empty
    end
    properties (Access = protected)
        Settings settings.AppSettings
        ButtonsGridColumnWidthWithText = [repmat({110}, 1, 7) {'1x' 110}];
        ButtonsGridColumnWidthOnlyIcon = [repmat({25}, 1, 7) {'1x' 25}];
        ButtonsTexts cell
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
        SidePanelGrid matlab.ui.container.GridLayout
        FitterPanel ui.TyreFitterPanel
        SearchBar ui.SearchBar
    end
    events (HasCallbackProperty, NotifyAccess = protected)
        FitterSettingsChanged
        FitterStartRequested
        TyreModelClearRequested
        TyreModelEdited
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
        KeyPressed
    end
    methods(Access = private)
        function onSearchPrevRequested(obj, ~, ~)
            notify(obj.TyreParametersTable, 'SearchPrevRequested')
        end
        function onSearchNextRequested(obj, ~, ~)
            notify(obj.TyreParametersTable, 'SearchNextRequested')
        end
        function onSearchResultsAvailable(obj, ~, e)
            notify(obj.SearchBar, 'SearchResultsAvailable', e)
        end
        function onKeyPressed(obj, ~, e)
            notify(obj.TyreParametersTable, 'KeyPressed', e)
        end
        function onSaveModelRequested(obj, ~, ~)
            notify(obj, 'TyreModelSaveRequested')
        end
        function onClearModelReq(obj, ~, ~)
            notify(obj, 'TyreModelClearRequested')
        end
        function onTyreModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
            e = events.ModelChangedEventData(model);
            notify(obj.TyreParametersTable, 'TyreModelChanged', e)
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
            s = obj.Settings.View.TyreModelPanel;
            showFitter = event.Value;
            s.ShowSidebar = showFitter;
            updateSidebar(obj)
        end
        function onFitterSettingsChanged(obj, ~, event)
            arguments
                obj
                ~
                event events.FitterSettingsChangedEventData
            end
            obj.Fitter.Options = event.Settings;
        end
        function onTyreModelFitterFinished(obj, ~, event)
            paramsFit = event.ParametersFitted;
            e = events.TyreModelFitterFinished(paramsFit);
            notify(obj.TyreParametersTable, 'TyreModelFitterFinished', e)
            set(obj.ApplyFittedButton, 'Enable', true)
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
        function onTyreModelEdited(obj, ~, ~)
            notify(obj, 'TyreModelEdited')
        end
        function onUiFigureSizeChanged(obj, ~, ~)
            parent = obj.Parent;
            while isa(parent, 'matlab.ui.container.GridLayout')
                parent = parent.Parent;
            end
            width = parent.Position(3);
            
            buttonsGrid = obj.ButtonsGrid;
            buttons = obj.ButtonsGrid.Children;
            % doesnt work due to two types of objects in array?
            %   positions = vertcat(btns(:).Position)
            % therefore using slower for-loop:
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
        function onSearchTextChanged(obj, ~, event)
            notify(obj.TyreParametersTable, 'SearchTextChanged', event)
        end
    end
    methods (Access = protected)
        function setupButtons(obj)
            s = settings.LayoutSettings();
            obj.ButtonsGrid = uigridlayout(obj.MainGrid, ...
                'RowHeight', {s.DefaultButtonHeight}, ...
                'ColumnWidth', obj.ButtonsGridColumnWidthWithText, ...
                'ColumnSpacing', s.DefaultColumnSpacing, ...
                'Padding', zeros(1,4));
            obj.ButtonsGrid.Layout.Column = [1 2];
            
            obj.NewModelButton = uibutton(obj.ButtonsGrid, ...
                'Text', 'New Model', ...
                'Tooltip', 'Creates new tyre model with default values.', ...
                'Icon', 'tyre_add_icon.svg', ...
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
                'Text', 'Show Sidebar', ...
                'Tooltip', 'Shows/Hides fitter panel.', ...
                'Icon', 'gears-solid.svg', ...
                'Enable', true, ...
                'Value', true, ...
                'ValueChangedFcn', @obj.onFitterStateButtonChanged);
            obj.FitterStateButton.Layout.Column = ...
                numel(obj.ButtonsGrid.ColumnWidth);
            
            btns = obj.ButtonsGrid.Children;
            obj.ButtonsTexts = [{btns(1:end-1).Text} {btns(end).Text}];
        end
        function setupTyreParametersTable(obj)
            obj.TyreParametersTable = ui.TyreParametersTable(obj.MainGrid, ...
                'TyreModelEditedFcn', @obj.onTyreModelEdited, ...
                'SearchResultsAvailableFcn', @obj.onSearchResultsAvailable);
            obj.TyreParametersTable.Layout.Row = 2;
            obj.TyreParametersTable.Layout.Column = [1 2];
        end
        function setupMainGrid(obj)
            s = settings.LayoutSettings();
            obj.MainGrid = uigridlayout(obj, ...
                'RowHeight', {s.DefaultButtonHeight,'1x'}, ...
                'ColumnWidth', {'1x', s.DefaultSidebarWidth}, ...
                'ColumnSpacing', s.DefaultColumnSpacing, ...
                'Padding', zeros(1,4), ...
                'Scrollable', false);
        end
        function setupSidePanel(obj)
            obj.SidePanelGrid = uigridlayout(obj.MainGrid, ...
                'RowHeight', {'fit', 'fit'}, ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4), ...
                'Scrollable', true, ...
                'Visible', true);
            obj.SidePanelGrid.Layout.Row = 2;
            obj.SidePanelGrid.Layout.Column = 2;
            
            obj.SearchBar = ui.SearchBar(obj.SidePanelGrid, ...
                'SearchTextChangedFcn', @obj.onSearchTextChanged, ...
                'SearchPrevRequested', @obj.onSearchPrevRequested, ...
                'SearchNextRequested', @obj.onSearchNextRequested);
            
            obj.FitterPanel = ui.TyreFitterPanel(obj.SidePanelGrid, ...
                'FitterSolverSettingsChangedFcn', ...
                @obj.onFitterSettingsChanged, .....
                'FitterStartRequestedFcn', ...
                @obj.onFitterStartRequested);
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onTyreModelChanged);
            addlistener(obj, 'TyreModelFitterFinished', ...
                @obj.onTyreModelFitterFinished);
            addlistener(obj, 'KeyPressed', @obj.onKeyPressed);
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            obj.Settings = settings.AppSettings();
            setupMainGrid(obj)
            setupButtons(obj)
            setupTyreParametersTable(obj)
            setupSidePanel(obj)
            setupListeners(obj)
            set(obj, 'SizeChangedFcn', @obj.onUiFigureSizeChanged)
        end
        function update(obj)
            updateButtons(obj)
            updateSidebar(obj)
        end
        function updateSidebar(obj)
            s = obj.Settings.View.TyreModelPanel;
            showSidebar = s.ShowSidebar;
            set(obj.SidePanelGrid, 'Visible', showSidebar)
            set(obj.FitterStateButton, 'Value', showSidebar)
            if showSidebar
                obj.TyreParametersTable.Layout.Column = 1;
            else
                obj.TyreParametersTable.Layout.Column = ...
                    [1 numel(obj.MainGrid.ColumnWidth)];
            end
        end
        function updateButtons(obj)
            buttons = [
                obj.SaveModelButton
                obj.ClearModelButton
                obj.ResetModelButton
                obj.StructToMatButton
                ];
            hasModelLoaded = ~isempty(obj.Model);
            enable = matlab.lang.OnOffSwitchState(hasModelLoaded);
            set(buttons, 'Enable', char(enable))
            set(obj.SidePanelGrid, 'Visible', hasModelLoaded)
            if ~hasModelLoaded
                set(obj.ApplyFittedButton, 'Enable', false)
            end
        end
    end
end
