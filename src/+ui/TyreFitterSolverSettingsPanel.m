classdef TyreFitterSolverSettingsPanel < matlab.ui.componentcontainer.ComponentContainer
    %FITTERSOLVERSETTINGSPANEL Panel to configure optimization settings of
    %fitter (fmincon).
    
    events (HasCallbackProperty, NotifyAccess = protected)
        SettingsChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        Panel                       matlab.ui.container.Panel
        Grid                        matlab.ui.container.GridLayout
        AlgorithmDropdown           matlab.ui.control.DropDown
        MaxFunEvalEditField         matlab.ui.control.EditField
        MaxIterEditField            matlab.ui.control.EditField
        ParpoolButton               matlab.ui.control.StateButton
    end
    
    properties (Dependent, Access = public)
        OptimizerOptions optim.options.Fmincon
    end
    
    properties (Access = private)
        Settings settings.AppSettings
    end
    
    methods
        function value = get.OptimizerOptions(obj)
            value = obj.Settings.Fitter.OptimizerSettings;
        end
        function set.OptimizerOptions(obj, value)
            obj.Settings.Fitter.OptimizerSettings = value;
        end
    end
    
    methods (Access = private)
        function onSettingsChanged(obj, ~, ~)
            opts = obj.OptimizerOptions;
            s = obj.Settings.Fitter;
            try
                opts.Algorithm = ...
                    obj.AlgorithmDropdown.Value;
                opts.MaxFunctionEvaluations = str2double(...
                    obj.MaxFunEvalEditField.Value);
                opts.MaxIterations =  str2double(...
                    obj.MaxIterEditField.Value);
                opts.UseParallel = logical(...
                    obj.ParpoolButton.Value);
            catch cause
                exception = exceptions.InvalidSolverOptions();
                exception = addCause(exception, cause);
                throw(exception)
            end
            s.OptimizerSettings.Algorithm = opts.Algorithm;
            s.OptimizerSettings.MaxFunctionEvaluations = opts.MaxFunctionEvaluations;
            s.OptimizerSettings.MaxIterations = opts.MaxIterations;
            s.OptimizerSettings.UseParallel = opts.UseParallel;
            e = events.FitterSettingsChangedEventData(opts);
            obj.OptimizerOptions = opts;
            notify(obj, 'SettingsChanged', e)
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 400 400];
            
            obj.Settings = settings.AppSettings();
            
            g = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));
            obj.Panel = uipanel(g, ...
                'Title', 'Optimization Settings', ...
                'BorderType', 'none');
            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', repmat({20}, 1, 4), ...
                'ColumnWidth', repmat({'fit'}, 1, 2), ...
                'Padding', 5*ones(1,4), ...
                'ColumnSpacing', 10);
            
            algorithms = {
                'interior-point'
                'trust-region-reflective'
                'sqp'
                'active-set'
                };
            obj.AlgorithmDropdown = uidropdown(obj.Grid, ...
                'Items', algorithms, ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'Algorithm');
            
            obj.MaxFunEvalEditField = uieditfield(obj.Grid, ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'MaxFunEvals');
            
            obj.MaxIterEditField = uieditfield(obj.Grid, ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'MaxIter');
            
            obj.ParpoolButton = uibutton(obj.Grid, 'state', ...
                'Text', 'Enable', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'UseParallel');
        end
        function update(obj)
            opts = obj.OptimizerOptions;
            obj.AlgorithmDropdown.Value = opts.Algorithm;
            obj.MaxFunEvalEditField.Value = num2str(opts.MaxFunEvals);
            obj.MaxIterEditField.Value = num2str(opts.MaxIter);
            obj.ParpoolButton.Value = opts.UseParallel;
        end
    end
end
