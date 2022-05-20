classdef MeasurementImporter < matlab.apps.AppBase
    
    properties (Access = public)
        MeasurementImported tydex.Measurement = tydex.Measurement.empty
        MeasurementFileFullPath     char
        OutputDirectoryFullPath     char
    end
    
    properties (Access = private)
        CallingApp                  matlab.ui.Figure
    end
    
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridMain                    matlab.ui.container.GridLayout
        GridConfig                  matlab.ui.container.GridLayout
        GridWindowButtons           matlab.ui.container.GridLayout
        MeasurementFileLabel        matlab.ui.control.Label
        MeasurementFileEditField    matlab.ui.control.EditField
        MeasurementFileDialogButton matlab.ui.control.Button
        ParserLabel                 matlab.ui.control.Label
        ParserDropdown              matlab.ui.control.DropDown
        ParserFileDialogButton      matlab.ui.control.Button
        StartImportButton           matlab.ui.control.Button
        CancelImportButton          matlab.ui.control.Button
    end
    
    methods (Access = private)
        function onCloseRequested(app, ~, ~)
            callingApp = app.CallingApp;
            if isempty(callingApp)
                delete(app)
            else
                callingApp = app.CallingApp;
                uiresume(callingApp)
            end
        end
        function onTestTypeChanged(app, source, ~)
            testType = source.Value;
            app.TestType = testType;
        end
        function chooseFileDialog(app, ~, ~)
            [file,path] = uigetfile('.mat', 'Select measurement file');
            if ~file; return; end
            fileFullPath = [path file];
            app.MeasurementFileEditField.Value = file;
            app.MeasurementFileFullPath = fileFullPath;
        end
        function chooseParserDialog(app, ~, ~)
            [fileName, path] = uigetfile('.m', 'Select parser class file');
            if path == 0
                return
            end
            [~, fileBaseName] = fileparts(fileName);
            pathParts = strsplit(path,filesep());
            packageFlag = '+';
            I = cellfun(@(x) startsWith(x, packageFlag),  pathParts);
            pathToPackage = fullfile(pathParts{~I});
            addpath(pathToPackage)
            packageParts = pathParts(I);
            packageParts = erase(packageParts, packageFlag);
            parserClassName = strjoin([packageParts fileBaseName], '.');
            
            superclassNames = superclasses(parserClassName);
            isParser = any(contains(superclassNames, 'tydex.Parser'));
            
            if ~isParser
                title = 'Choose Parser';
                message = ['Invalid parser selected. Must inherit from ' ...
                    '"tydex.Parser".'];
                uialert(app.UIFigure, message, title, 'icon', 'error')
                return
            end
            
            item = [fileBaseName ' (custom)'];
            itemData = parserClassName;
            
            dd = app.ParserDropdown;
            dd.Items = [{item} dd.Items];
            dd.ItemsData = [{itemData} dd.ItemsData];
            dd.Value = itemData;
        end
        function runImport(app, ~, ~)
            file = app.MeasurementFileFullPath;
            if isempty(file)
                uialert(app.UIFigure, ...
                    'No measurement file selected', ...
                    'Import failed');
                return
            end
            fig = app.UIFigure;
            dlg = uiprogressdlg(fig, ...
                'Title', 'Importing measurement file',...
                'Message', 'Please wait...', ...
                'Indeterminate','on');
            
            try
                parserClassName = app.ParserDropdown.Value;
                parser = eval(parserClassName);
                measurement = parser.run(file);
                app.MeasurementImported = measurement;
            catch ME
                close(dlg)
                uialert(app.UIFigure, ME.message, 'Import failed');
                return
            end
            close(dlg)
            uialert(app.UIFigure, ...
                'Measurement has been imported.', ...
                'Import successful', ...
                'Icon', 'success', ...
                'CloseFcn', @app.onCloseRequested);
        end
    end
    
    methods (Access = private)
        function startupFcn(app)
        end
        function createComponents(app)
            if ~isempty(app.CallingApp)
                name = app.CallingApp.Name;
                name = [name ' - Measurement Importer'];
            else
                name = 'Measurement Importer';
            end
            app.UIFigure = uifigure(...
                'Name', name, ...
                'Visible', 'off',...
                'HandleVisibility', 'off', ...
                'Resize', 'off', ...
                'Color',[1 1 1], ...
                'Position', [500 500 500 200], ...
                'Icon', 'tyre_icon.png', ...
                'CloseRequestFcn', @app.onCloseRequested, ...
                'WindowStyle', 'modal');
            
            app.GridMain = uigridlayout(app.UIFigure, ...
                'Padding', 10*ones(1,4), ...
                'RowSpacing', 20, ...
                'RowHeight', {'fit', '1x', 'fit'}, ...
                'ColumnWidth', {'1x'});
            
            app.GridConfig = uigridlayout(app.GridMain, ...
                'Padding', 0*ones(1,4), ...
                'RowHeight', {'fit','fit'}, ...
                'ColumnWidth', {'fit','fit','1x','fit'});
            
            app.MeasurementFileLabel = uilabel(app.GridConfig, ...
                'Text', 'Measurement File');
            app.MeasurementFileLabel.Layout.Row = 1;
            
            helpHint = ui.HelpHint(app.GridConfig);
            helpHint.Tooltip = ['Measurement file must be a single file. ' ...
                'Depending on the Parser used, it can be MAT or any other ' ...
                'file format.'];
            
            app.MeasurementFileEditField = uieditfield(app.GridConfig, ...
                'Editable', 'off');
            app.MeasurementFileEditField.Layout.Row = 1;
            
            app.MeasurementFileDialogButton = uibutton(app.GridConfig, ...
                'Text', 'Choose...', ...
                'ButtonPushedFcn', @app.chooseFileDialog);
            app.MeasurementFileDialogButton.Layout.Row = 1;
            
            app.ParserLabel = uilabel(app.GridConfig, ...
                'Text', 'Parser');
            app.ParserLabel.Layout.Row = 2;
            
            helpHint = ui.HelpHint(app.GridConfig);
            helpHint.Tooltip = ['Parser must inherit from base class ' ...
                '"tydex.Parser". Some parser come with the MF-Tyre ' ...
                'library, but you might have to build your own.' ...
                newline() newline() ...
                'A parser must create "tydex.Measurement" objects from ' ...
                'a given measurement file.'];
            
            [parserNames, parserClassNames] = app.getParserNames();
            app.ParserDropdown = uidropdown(app.GridConfig, ...
                'Items', parserNames, ...
                'ItemsData', parserClassNames, ...
                'Tooltip', ['Currently only FSAE TTC data '...
                'in SI units supplied as .mat file is suppored.']);
            app.ParserDropdown.Layout.Row = 2;
            
            app.ParserFileDialogButton = uibutton(app.GridConfig, ...
                'Text', 'Choose...', ...
                'ButtonPushedFcn', @app.chooseParserDialog);
            
            app.GridWindowButtons = uigridlayout(app.GridMain, ...
                'Padding', zeros(1,4), ...
                'RowHeight', {22}, ...
                'ColumnWidth', {'1x', 100, 100});
            app.GridWindowButtons.Layout.Row = 3;
            
            app.StartImportButton = uibutton(app.GridWindowButtons, ...
                'Text', 'Import', ...
                'BackgroundColor', [144, 202, 249]/255, ...
                'ButtonPushedFcn', @app.runImport);
            app.StartImportButton.Layout.Column = 2;
            
            app.CancelImportButton = uibutton(app.GridWindowButtons, ...
                'Text', 'Cancel', ...
                'ButtonPushedFcn', @(o,e) close(app.UIFigure));
            app.CancelImportButton.Layout.Column = 3;
            
            app.UIFigure.Visible = 'on';
        end
    end
    
    methods (Static, Access = private)
        function [parserNames, parserClassNames] = getParserNames()
            try
                parsersMetaObj = meta.package.fromName('tydex.parsers');
                parserMetaClassObjs = parsersMetaObj.ClassList;
                isAbstract = [parserMetaClassObjs.Abstract];
                parserMetaClassObjs(isAbstract) = [];
                parserClassNames = {parserMetaClassObjs.Name};
                parserNamesSplit = cellfun(...
                    @(x) strsplit(x, '.'), parserClassNames, ...
                    'UniformOutput', false);
                parserNames = cellfun(@(x) x{end},  parserNamesSplit,  ...
                    'UniformOutput',  false);
            catch
                warning('Could not find any pre-installed parsers!')
                [parserNames, parserClassNames] = deal({});
            end
        end
    end
    
    methods (Access = public)
        function app = MeasurementImporter(varargin)
            if nargin == 1
                callingApp = varargin{1};
                app.CallingApp = callingApp;
            end
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
            delete(app.UIFigure)
        end
    end
end