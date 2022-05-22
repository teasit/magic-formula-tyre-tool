classdef (Sealed) MFTyreTool < matlab.apps.AppBase
    %MFTYRETOOL GUI for creating and analysing Pacejka MFTyre models.
    %   This tool is dependent on the MFTyre-MATLAB-Library found on
    %   Github: https://github.com/teasit/mftyre-matlab-library
    %
    
    properties (Access = private)
        TyreModel mftyre.Model = mftyre.v62.Model.empty()
        TyreModelBackup mftyre.Model = mftyre.v62.Model.empty()
        TyreModelFitted mftyre.Model = mftyre.v62.Model.empty()
        TyreMeasurements tydex.Measurement
        TyreModelFitter mftyre.v62.Fitter
        TyreModelFitterFitModes mftyre.v62.FitMode
        
        %View settings, e.g. state of table filters
        ViewSettings ui.ViewSettings
    end
    properties (Constant, Access = private)
        %Stores about configuration values, e.g. application version.
        About struct = MFTyreTool.initAboutConfiguration()
        
        %Logfile name. Only relevant for deployed application.
        Logfile char = 'logfile.txt'
        
        %Stores default solver (fmincon) settings e.g. max iterations.
        SolverOptionsDefault = MFTyreTool.initSolverOptions()
    end
    properties (Transient, Access = private)
        %If user selects a directory, it is saved and reused to accelerate
        %following user actions.
        LastUsedDirectoryByUser char
    end
    properties (Access = ?ui.MFTyreToolChart)
        UIFigure                matlab.ui.Figure
        TabGroupPrimary         matlab.ui.container.TabGroup
        TabGroupSecondary       matlab.ui.container.TabGroup
        GridMain                matlab.ui.container.GridLayout
        
        AppMenu                 matlab.ui.container.Menu
        HelpMenu                matlab.ui.container.Menu
        ViewMenu                matlab.ui.container.Menu
        
        TyreModelFittingTab     matlab.ui.container.Tab
        TyreModelPanel          ui.TyreModelPanel
        TyreModelGrid           matlab.ui.container.GridLayout
        
        TyreMeasurementsTab     matlab.ui.container.Tab
        TyreMeasurementsTabGrid matlab.ui.container.GridLayout
        TyreMeasurementsPanel   ui.TyreMeasurementsPanel
        
        TyreModelAnalysisTab    matlab.ui.container.Tab
        TyreModelAnalysisGrid   matlab.ui.container.GridLayout
        TyreAnalysisPanel       ui.TyreAnalysisPanel
        
        UiChart                 ui.MFTyreToolChart
    end
    methods (Static, Access = private)
        function config = initAboutConfiguration()
            file = 'about.json';
            text = fileread(file);
            config = jsondecode(text);
        end
        function opts = initSolverOptions()
            opts = optimoptions('fmincon');
            opts.MaxFunctionEvaluations = 3000;
            opts.MaxIterations = 1000;
            opts.UseParallel = false;
        end
        function file = dialogSaveTyreModel(model)
            filter = '.tir';
            defname = 'mftyre.tir';
            prompt = 'Choose name for Tyre Properties File';
            [fileName, path] = uiputfile(filter, prompt, defname);
            if path == 0
                file = char.empty;
                return
            end
            file = fullfile(path, fileName);
            try
                model.exportTyrePropertiesFile(file);
            catch sourceException
                baseException = exceptions.CouldNotExportTIR(fileName);
                baseException = addCause(baseException, sourceException);
                throw(baseException)
            end
        end
    end
    methods (Access = private)
        function params = extractNominalParametersFromMeasurements(app)
            measurements = app.TyreMeasurements;
            if isempty(measurements)
                params = [];
                return
            end
            constants = measurements(end).Constant;
            constantNames = {constants.Name};
            queryNames = {'FNOMIN', 'NOMPRES'};
            I = contains(constantNames, queryNames);
            params = constants(I);
        end
        function dialogApplyParamsFromMeasurements(app, params)
            fig = app.UIFigure;
            
            numParams = numel(params);
            paramStrings = cell(numParams,1);
            for i = 1:numParams
                p = params(i);
                str = sprintf('%s = %d%s', p.Name, p.Value, p.Unit);
                paramStrings{i,1} = str;
            end
            
            msgParams = strjoin(paramStrings, '\n');
            msg = sprintf(['The following parameters were detected ' ...
                'automatically in the loaded measurements: \n\n%s\n\n' ...
                'Do you want to apply these values to your model?'], ...
                msgParams);
            optApply = 'Apply';
            optCancel = 'No';
            userSelection = uiconfirm(fig, msg, ...
                'Parameters detected in measurements', ...
                'Options', {optApply, optCancel}, ...
                'DefaultOption', optApply, ...
                'CancelOption', optCancel);
            
            switch userSelection
                case optApply
                    model = app.TyreModel;
                    for i = 1:numel(params)
                        name = params(i).Name;
                        value = params(i).Value;
                        model.Parameters.(name).Value = value;
                    end
                    app.TyreModel = model;
                case optCancel
                    return
            end
        end
    end
    methods (Access = private)
        function onUiFigureSizeChanged(app, ~, ~)
            position = app.UIFigure.Position;
            width = position(3);
            height = position(4);
        end
        function onTyreModelEdited(app, ~, ~)
            model = app.TyreModel;
            evtdata = events.ModelChangedEventData(model);
            notify(app.TyreAnalysisPanel, 'TyreModelChanged', evtdata)
        end
        function onShowLogfileRequested(app, ~, ~)
            if ~isdeployed()
                disp(['Logfile only available in deployed application. ' ...
                    'See console window instead.'])
                commandwindow()
                return
            end
            
            logfile = app.Logfile;
            if ispc()
                winopen(logfile)
            else
                open(logfile)
            end
        end
        function onFitterFittingModesChanged(app, ~, event)
            modes = event.FitModes;
            app.TyreModelFitterFitModes = modes;
        end
        function onLoadModelRequested(app, ~, ~)
            [fileName, path] = uigetfile('.tir', ...
                'Select Tyre Properties File');
            userCanceled = path == 0;
            if userCanceled
                return
            end
            
            file = fullfile(path, fileName);
            try
                model = mftyre.v62.Model;
                model.importTyrePropertiesFile(file)
                app.setTyreModel(model)
            catch cause
                exception = exceptions.CouldNotImportTIR(fileName);
                exception = addCause(exception, cause);
                throw(exception)
            end
        end
        function onClearModelRequested(app, ~, ~)
            delete(app.TyreModel)
            delete(app.TyreModelBackup)
            modelEmpty = mftyre.v62.Model.empty;
            app.setTyreModel(modelEmpty)
        end
        function onImportMeasurementsRequested(app, ~, ~)
            fig = app.UIFigure;
            
            importer = ui.MeasurementImporter(fig);
            try
                uiwait(fig);
                measurements = importer.MeasurementImported;
                delete(importer)
                if isempty(measurements)
                    uiresume(fig)
                    return
                end
                measurements = [app.TyreMeasurements measurements];
                app.setTyreMeasurementData(measurements)
                
                model = app.TyreModel;
                if ~isempty(model)
                    nominalParams = app.extractNominalParametersFromMeasurements();
                    app.dialogApplyParamsFromMeasurements(nominalParams)
                end
            catch ME
                delete(importer)
                uiresume(fig)
                rethrow(ME)
            end
        end
        function onExportMeasurementsRequested(app, ~, ~)
            measurements = app.TyreMeasurements;
            
            if isempty(measurements)
                return
            end
            
            opendir = app.LastUsedDirectoryByUser;
            title = 'Select Export Directory for TYDEX Measurement Files';
            savedir = uigetdir(opendir, title);
            if savedir == 0
                return
            end
            app.LastUsedDirectoryByUser = savedir;
            
            title = 'Export Measurements';
            fig = app.UIFigure;
            msg = ['Exporting measurements as TYDEX files to the ' ...
                'following directory:' ...
                sprintf('\n\t%s', savedir)];
            dlg = uiprogressdlg(fig, ...
                'Title', title,...
                'Message', msg, ...
                'Indeterminate','on', ...
                'Cancelable', 'off');
            
            try
                measurements.save(savedir)
            catch cause
                close(dlg)
                msg = 'Export failed. See console/logfile for details';
                uialert(fig, msg, title, 'Icon', 'error')
                
                exception = exceptions.CouldNotExportTYDEX();
                exception = exception.addCause(cause);
                throw(exception)
            end
            msg = 'Export successful.';
            uialert(fig, msg, title, 'Icon', 'success')
        end
        function onClearMeasurementsRequested(app, ~, ~)
            message = 'Clear loaded measurements?';
            title = 'Clear Measurements';
            options = {'Yes', 'Cancel'};
            selection = uiconfirm(app.UIFigure, message, title, ...
                'Icon', 'warning');
            userCancel = strcmp(selection, options{end});
            if userCancel
                return
            end
            
            measurementsEmpty = tydex.Measurement.empty;
            app.setTyreMeasurementData(measurementsEmpty)
        end
        function onAboutDialogRequested(app, ~, ~)
            fig = app.UIFigure;
            title = 'About';
            about = app.About;
            fn = fieldnames(about);
            message = char.empty;
            for i = 1:numel(fn)
                if i ~= 1
                    message = [message newline()];
                end
                field = fn{i};
                value = about.(field);
                if iscell(value)
                    paragraph = [
                        field ':' newline() ...
                        sprintf('\t - %s\n', value{:})
                        ];
                else
                    paragraph = [field ': ' value newline()];
                end
                message = [message paragraph];
            end
            uialert(fig, message, title, 'Icon', 'info')
        end
        function onResetApplicationRequested(app, ~, ~)
            message = 'All unsaved progress will be lost. Continue?';
            title = 'Reset Application';
            options = {'Yes', 'Cancel'};
            selection=  uiconfirm(app.UIFigure, message, title, ...
                'Icon', 'warning');
            userCancel = strcmp(selection, options{end});
            if userCancel
                return
            end
            
            reset(app)
        end
        function onFitterModelChanged(app, ~, event)
            drawnow
            model = event.Model;
            app.TyreAnalysisPanel.Model = model;
        end
        function onFitterMeasurementsLoaded(app, ~, event)
            arguments
                app
                ~
                event events.FitterMeasurementsLoadedEventData
            end
            flagsMap = event.FitModeFlags;
            app.TyreMeasurementsPanel.addMeasurementFitModes(flagsMap);
        end
        function onStartFittingRequested(app, ~, ~)
            import mftyre.v62.FitMode
            
            fig = app.UIFigure;
            title = 'Tyre Model Fitter';
            message = sprintf(['To start fitting, the following conditions ' ...
                'must be met:' newline() ...
                '\t- Tyre model loaded' newline() ...
                '\t- Tyre data loaded' newline() ...
                '\t- Fit modes selected (Fx0, Fy0, Fx, ...)']);
            showUserFail = @(x) uialert(fig, message, title, 'Icon', 'error');
            
            tyreModel = app.TyreModel;
            if isempty(tyreModel)
                showUserFail()
                return
            end
            
            tyreModelFitted = copy(tyreModel);
            params = tyreModel.Parameters;
            measurements = app.TyreMeasurements;
            fitmodes = app.TyreModelFitterFitModes;
            
            if isempty(params) || isempty(measurements) || isempty(fitmodes)
                showUserFail()
                return
            end
            
            fitter = app.TyreModelFitter;
            fitter.Parameters = params;
            fitter.Measurements = measurements;
            fitter.FitModes = fitmodes;
            
            message = 'Starting Fitter...';
            dlg = uiprogressdlg(fig, ...
                'Title', title, ...
                'Message', message, ...
                'Indeterminate','on', ...
                'Cancelable', 'on');
            
            outputFcn = @(x,optimValues,state) ...
                helpers.fitterOutputFcn(x,optimValues,state,dlg,fitter);
            fitter.Options.OutputFcn = outputFcn;
            
            try
                fitter.run()
                
                paramsFitted = fitter.ParametersFitted;
                tyreModelFitted.Parameters = paramsFitted;
                app.TyreModelFitted = tyreModelFitted;
                
                
                e = events.TyreModelFitterFinished(paramsFitted);
                notify(app.TyreModelPanel, 'TyreModelFitterFinished', e)
                
                cancelByUser = dlg.CancelRequested;
                close(dlg)
                
                if cancelByUser
                    message = 'Fitting process aborted by user.';
                    icon = 'info';
                else
                    message = 'Fitting process successful.';
                    icon = 'success';
                end
                message = [message newline() ...
                    'Parameters of last iteration written to table.' ...
                    newline() newline() ...
                    'Details printed to logfile/console.'];
                uialert(fig, message, title, 'icon', icon)
            catch ME
                paramsFitted = mftyre.v62.Parameters.empty;
                e = events.TyreModelFitterFinished(paramsFitted);
                notify(app.TyreModelPanel, 'TyreModelFitterFinished', e)
                
                close(dlg)
                
                message = ['Fitting process FAILED!' newline()...
                    'Details printed to logfile/console.'];
                uialert(fig, message, title, 'icon', 'error')
                
                rethrow(ME)
            end
        end
        function onNewTyreModelRequested(app, ~, ~)
            model = app.TyreModel;
            if ~isempty(model)
                message = 'Current tyre model will be deleted. Continue?';
                title = 'New Tyre Model';
                optYes = 'Yes';
                optCancel = 'Cancel';
                options = {optYes, optCancel};
                selection = uiconfirm(app.UIFigure, message, title, ...
                    'Options', options, 'Icon', 'warning');
                if strcmp(selection, optCancel)
                    return
                end
            end
            
            modelNew = mftyre.v62.Model();
            file = MFTyreTool.dialogSaveTyreModel(modelNew);
            if isempty(file)
                return
            end
            app.setTyreModel(modelNew)
            modelNew.File = file;
        end
        function onSaveTyreModelRequested(app, ~, ~)
            model = app.TyreModel;
            if isempty(model)
                return
            end
            
            file = model.File;
            if isempty(file)
                app.setTyreModel(model)
                model = app.TyreModel;
                file = MFTyreTool.dialogSaveTyreModel(model);
                model.File = file;
                return
            end
            
            optOverwrite = 'Overwrite';
            optNew = 'Save as...';
            optCancel = 'Cancel';
            options = {optOverwrite, optNew, optCancel};
            message = 'Imported file will be overwritten. Continue?';
            title = 'Save Tyre Model';
            selection = uiconfirm(app.UIFigure, message, title, ...
                'Options', options, 'Icon', 'warning');
            
            switch selection
                case optCancel
                    return
                case optOverwrite
                    app.setTyreModel(model)
                    model = app.TyreModel;
                    model.exportTyrePropertiesFile(file);
                case optNew
                    app.setTyreModel(model)
                    model = app.TyreModel;
                    file = MFTyreTool.dialogSaveTyreModel(model);
                    model.File = file;
            end
        end
        function onResetTyreModelRequested(app, ~, ~)
            backupModel = app.TyreModelBackup;
            
            message = 'Unsaved changes will be discarded. Continue?';
            title = 'Reset Tyre Model';
            options = {'Yes', 'Cancel'};
            selection = uiconfirm(app.UIFigure, message, title, ...
                'Icon', 'warning');
            userCancel = strcmp(selection, options{end});
            if userCancel
                return
            end
            
            app.setTyreModel(backupModel)
        end
        function onClearTyreModelRequested(app, ~, ~)
            model = app.TyreModel;
            modelBackup = app.TyreModelBackup;
            
            hasUnsavedChanges = model.Parameters ~= modelBackup.Parameters;
            if hasUnsavedChanges
                message = 'Tyre model has unsaved changes. Continue?';
                title = 'Clear Tyre Model';
                options = {'Yes', 'Cancel'};
                selection=  uiconfirm(app.UIFigure, message, title, ...
                    'Icon', 'warning');
                userCancel = strcmp(selection, options{end});
                if userCancel
                    return
                end
            end
            
            model = mftyre.v62.Model.empty();
            app.setTyreModel(model)
        end
        function onViewMenuSelected(app, source, ~)
            viewSettings = app.ViewSettings;           
            tag = source.Tag;
            tagParent = source.Parent.Tag;
            valueOld = logical(source.Checked);
            valueNew = ~valueOld;
            
            viewSettings.(tagParent).(tag) = valueNew;
            set(source, 'Checked', valueNew);
            
            app.setViewSettings(viewSettings)
        end
        function onApplyFittedTyreModelRequested(app, ~, ~)
            tyreModelFitted = app.TyreModelFitted;
            if isempty(tyreModelFitted)
                return
            end
           
            fig = app.UIFigure;
            msg = ['Do you want to apply the parameter values found by ' ...
                'the fitter? Unsaved changes of your model will be ' ...
                'overwritten.'];
            optApply = 'Apply';
            optCancel = 'No';
            userSelection = uiconfirm(fig, msg, ...
                'Parameters detected in measurements', ...
                'Options', {optApply, optCancel}, ...
                'DefaultOption', optApply, ...
                'CancelOption', optCancel);
            if strcmp(userSelection, optCancel)
                return
            end
            
            app.setTyreModel(tyreModelFitted, false)
        end
        function onTyreModelStructToMatRequested(app, ~, ~)
            filter = '.mat';
            defname = 'mftyre_model_parameters.mat';
            prompt = 'Choose name for MAT file';
            [fileName, path] = uiputfile(filter, prompt, defname);
            if path == 0
                return
            end
            file = fullfile(path, fileName);
            mfparams = app.TyreModel.Parameters;
            mfparams = struct(mfparams);
            save(file, 'mfparams')
        end
        function onPlotTyreMeasurementsRequested(app, ~, event)
            measurements = event.Measurements;
            fig = app.UIFigure;
            title = 'Tyre Data Stacked Plot';
            if isempty(measurements)
                message = 'No measurements selected in table.';
                uialert(fig, message, title, 'Icon', 'info')
                return
            elseif numel(measurements) > 1
                message = ['Can only plot one measurement at a time.' ...
                    newline() 'Please select only one row in the table.'];
                uialert(fig, message, title, 'Icon', 'info')
                return
            end
            m = measurements;
            metadata = m.Metadata;
            I = strcmp({metadata.Name}, 'MEASID');
            measurementName = metadata(I).Value;
            
            measuredObjs = m.Measured;
            measuredNames = {measuredObjs.Name};
            I = strcmp(measuredNames, 'RUNTIME');
            measuredObjs(I) = [];
            measuredNames = {measuredObjs.Name};
            
            sz = [numel(m.RUNTIME) numel(measuredObjs)];
            type = class(m.RUNTIME);
            tbl = timetable('Size', sz, ...
                'VariableTypes', repmat({type}, [1 sz(2)]), ...
                'RowTimes', seconds(m.RUNTIME), ...
                'VariableNames', measuredNames);
            
            for i = 1:numel(measuredObjs)
                measured = measuredObjs(i);
                data = measured.Data;
                name = measured.Name;
                tbl.(name) = data;
            end
            
            f = figure('Name', measurementName);
            stackedplot(f, tbl, 'Marker', '.', 'LineStyle', 'none');
            grid on
        end
    end
    methods (Access = private)
        function createComponents(app)
            if isempty(app.UIFigure)
                createUIFigure(app)
            end
            createGrid(app)
            createTabGroups(app)
            createTyreModelTab(app)
            createTyreMeasurementsTab(app)
            createTyreAnalysisTab(app)
            createMenus(app)
            set(app.UIFigure, 'Visible', 'on');
        end
        function createUIFigure(app)
            about = app.About;
            name = sprintf('%s %s', about.Name, about.Version);
            position = groot().ScreenSize;
            position(1:2) = position(3:4)*0.2;
            position(3:4) = position(3:4)*0.6;
            app.UIFigure = uifigure(...
                'Visible', 'off',...
                'Tag', 'MainUIFigure', ...
                'HandleVisibility', 'on', ...
                'Color', [1 1 1], ...
                'Position', position, ...
                'Name', name, ...
                'Icon', 'tyre_icon.png', ...
                'AutoResizeChildren', 'off');
            app.UIFigure.SizeChangedFcn = @app.onUiFigureSizeChanged;
        end
        function createGrid(app)
            app.GridMain = uigridlayout(app.UIFigure, ...
                'Padding', zeros(1,4), ...
                'RowSpacing', 0, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x','1x'}, ...
                'ColumnSpacing', 0);
        end
        function createTabGroups(app)
            app.TabGroupPrimary = uitabgroup(app.GridMain);
            app.TabGroupSecondary = uitabgroup(app.GridMain);
        end
        function createTyreModelTab(app)
            app.TyreModelFittingTab = uitab(app.TabGroupPrimary, ...
                'Title', 'Tyre Model');
            app.TyreModelGrid = uigridlayout(app.TyreModelFittingTab, ...
                'Padding', 10*ones(1,4), ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'});
            app.TyreModelPanel = ui.TyreModelPanel(app.TyreModelGrid, ...
                'LoadTyreModelDialogReqestedFcn', @app.onLoadModelRequested, ...
                'TyreModelResetRequestedFcn', @app.onResetTyreModelRequested, ...
                'TyreModelNewRequestedFcn', @app.onNewTyreModelRequested, ...
                'TyreModelSaveRequested', @app.onSaveTyreModelRequested, ...
                'TyreModelApplyFittedRequested', @app.onApplyFittedTyreModelRequested, ...
                'TyreModelStructToMatRequested', @app.onTyreModelStructToMatRequested, ...
                'TyreModelClearRequested', @app.onClearTyreModelRequested, ...
                'FitterFittingModesChangedFcn', @app.onFitterFittingModesChanged, ...
                'FitterStartRequestedFcn', @app.onStartFittingRequested, ...
                'TyreModelEditedFcn', @app.onTyreModelEdited);
        end
        function createTyreMeasurementsTab(app)
            app.TyreMeasurementsTab = uitab(...
                app.TabGroupPrimary, ...
                'Title', 'Tyre Data');
            app.TyreMeasurementsTabGrid = uigridlayout(...
                app.TyreMeasurementsTab, ...
                'Padding', 10*ones(1,4), ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'});
            app.TyreMeasurementsPanel = ui.TyreMeasurementsPanel(...
                app.TyreMeasurementsTabGrid, ...
                'MeasurementDataImportRequestedFcn', ...
                @app.onImportMeasurementsRequested, ...
                'MeasurementDataClearRequestedFcn', ...
                @app.onClearMeasurementsRequested, ...
                'MeasurementDataExportRequestedFcn', ...
                @app.onExportMeasurementsRequested, ...
                'PlotTyreMeasurementsRequestedFcn', ...
                @app.onPlotTyreMeasurementsRequested);
        end
        function createTyreAnalysisTab(app)
            app.TyreModelAnalysisTab = uitab(...
                app.TabGroupPrimary, ...
                'Title', 'Tyre Analysis');
            app.TyreModelAnalysisGrid = uigridlayout(...
                app.TyreModelAnalysisTab, ...
                'Padding', 10*ones(1,4), ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'});
            app.TyreAnalysisPanel = ui.TyreAnalysisPanel(...
                app.TyreModelAnalysisGrid);
        end
        function createMenus(app)
            createAppMenu(app)
            createViewMenu(app)
            createHelpMenu(app)
        end
        function createAppMenu(app)
            app.AppMenu = uimenu(app.UIFigure, 'Text', 'App');
            %TODO: remove disabled state when fully implemented
            uimenu(app.AppMenu, ...
                'Text', '&New Tyre Model', ...
                'Accelerator', 'N', ...
                'MenuSelectedFcn', @app.onNewTyreModelRequested);
            uimenu(app.AppMenu, ...
                'Text', '&Open Tyre Model', ...
                'Accelerator', 'O', ...
                'MenuSelectedFcn', @app.onLoadModelRequested);
            uimenu(app.AppMenu, ...
                'Text', '&Save Tyre Model', ...
                'Accelerator', 'S', ...
                'MenuSelectedFcn', @app.onSaveTyreModelRequested);
            uimenu(app.AppMenu, ...
                'Text', '&Clear Tyre Model', ...
                'MenuSelectedFcn', @app.onClearModelRequested);
            
            uimenu(app.AppMenu, ...
                'Text', '&Import Tyre Data', ...
                'Accelerator', 'I', ...
                'MenuSelectedFcn', @app.onImportMeasurementsRequested, ...
                'Separator', 'on');
            uimenu(app.AppMenu, ...
                'Text', 'Clear Tyre Data', ...
                'MenuSelectedFcn', @app.onClearMeasurementsRequested);
            
            uimenu(app.AppMenu, ...
                'Text', 'Start &Fitter', ...
                'Accelerator', 'F', ...
                'MenuSelectedFcn', @app.onStartFittingRequested, ...
                'Separator', 'on');
            
            uimenu(app.AppMenu, ...
                'Text', '&Reset Application', ...
                'Accelerator', 'R', ...
                'Separator', 'on', ...
                'MenuSelectedFcn', @app.onResetApplicationRequested)
            uimenu(app.AppMenu, ...
                'Text', 'Show &Logfile', ...
                'Accelerator', 'L', ...
                'MenuSelectedFcn', @app.onShowLogfileRequested);
        end
        function createViewMenu(app)
            app.ViewMenu = uimenu(app.UIFigure, 'Text', 'View');
            
            m = uimenu(app.ViewMenu, ...
                'Text', 'Tyre Model Parameter Table', ...
                'Tag', 'TyreParametersTableViewSettings');
            uimenu(m, ...
                'Text', 'Show Fittable Parameters', ...
                'Tag', 'ShowFittableParameters', ...
                'Checked', true, ...
                'MenuSelectedFcn', @app.onViewMenuSelected);
            uimenu(m, ...
                'Text', 'Show Non-Fittable Parameters', ...
                'Tag', 'ShowNonFittableParameters', ...
                'Checked', true, ...
                'MenuSelectedFcn', @app.onViewMenuSelected);
            uimenu(m, ...
                'Text', 'Show Only Fit-Mode Parameters', ...
                'Tag', 'ShowOnlyFitModeParameters', ...
                'Checked', false, ...
                'MenuSelectedFcn', @app.onViewMenuSelected);
            
            m = uimenu(app.ViewMenu, ...
                'Text', 'Layout', ...
                'Tag', 'ViewLayoutSettings');
            uimenu(m, ...
                'Text', 'Analysis Tab on Secondary TabGroup', ...
                'Tag', 'MoveAnalysisPanelToSecondaryTabGroup', ...
                'Checked', false, ...
                'MenuSelectedFcn', @app.onViewMenuSelected);

        end
        function createHelpMenu(app)
            app.HelpMenu = uimenu(app.UIFigure, 'Text', 'Help');
            uimenu(app.HelpMenu, ...
                'Text', 'About', ...
                'MenuSelectedFcn', @app.onAboutDialogRequested)
        end
    end
    methods (Access = private)
        function startupFcn(app)
            model = mftyre.v62.Model.empty();
            app.setTyreModel(model)
            
            fitter = mftyre.v62.Fitter();
            app.TyreModelFitter = fitter;
            app.TyreModelPanel.Fitter = fitter;
            
            measurements = tydex.Measurement.empty();
            app.setTyreMeasurementData(measurements);
            
            viewSettings = ui.ViewSettings();
            setViewSettings(app, viewSettings)
            
            app.UiChart = ui.MFTyreToolChart('app', app, ...
                'viewSettings', viewSettings);
        end
        function setTyreModel(app, model, overwriteBackup)
            arguments
                app
                model mftyre.v62.Model
                overwriteBackup logical = true
            end
            if app.TyreModel ~= model
                delete(app.TyreModel)
            end
            modelCopy = copy(model);
            app.TyreModel = modelCopy;
            if overwriteBackup
                app.TyreModelBackup = model;
            end
            evtdata = events.ModelChangedEventData(modelCopy);
            notify(app.TyreModelPanel, 'TyreModelChanged', evtdata)
            notify(app.TyreAnalysisPanel, 'TyreModelChanged', evtdata)
            app.TyreModelPanel.Model = modelCopy;
        end
        function setTyreMeasurementData(app, measurements)
            fitter = app.TyreModelFitter;
            fitter.Measurements = measurements;
            flags = fitter.FitModeFlags;
            
            app.TyreMeasurements = measurements;
            app.TyreAnalysisPanel.Measurements = measurements;
            
            e = events.TyreMeasurementsChanged(measurements, flags);
            notify(app.TyreMeasurementsPanel, 'MeasurementDataChanged', e);
        end
        function setViewSettings(app, viewSettings)
            app.ViewSettings = viewSettings;
            app.UiChart.ViewSettingsChanged();
            event = events.ViewSettingsChanged(viewSettings);
            notify(app.TyreModelPanel, 'ViewSettingsChanged', event)
        end
    end
    methods (Access = public)
        function reset(app)
            %RESET Resets application without closing current window.
            fig = app.UIFigure;
            dlg = uiprogressdlg(fig, 'Title', 'Reset Application', ...
                'Message', 'Please wait.', 'Indeterminate', 'on');
            
            children = fig.Children;
            delete(children)
            
            metaClass = ?MFTyreTool;
            metaProperties = metaClass.PropertyList;
            isTransient = [metaProperties.Transient];
            hasDefault = [metaProperties.HasDefault];
            isConstant = [metaProperties.Constant];
            I = ~isTransient & hasDefault & ~isConstant;
            metaProperties = metaProperties(I);
            for i = 1:numel(metaProperties)
                metaProperty = metaProperties(i);
                propName = metaProperty.Name;
                propDefault = metaProperty.DefaultValue;
                app.(propName) = propDefault;
            end
            
            createComponents(app)
            runStartupFcn(app, @startupFcn)
            
            close(dlg)
        end
        function app = MFTyreTool
            runningApp = getRunningApp(app);
            
            if isempty(runningApp)
                createComponents(app)
                registerApp(app, app.UIFigure)
                runStartupFcn(app, @startupFcn)
            else
                figure(runningApp.UIFigure)
                app = runningApp;
            end
            
            if nargout == 0
                clear app
            end
        end
        function delete(app)
            delete(app.TyreModel)
            delete(app.TyreModelBackup)
            delete(app.TyreModelFitter)
            delete(app.UIFigure)
        end
    end
end
