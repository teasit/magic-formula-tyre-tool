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
        MaxFunEvalEditField         matlab.ui.control.NumericEditField
        MaxIterEditField            matlab.ui.control.NumericEditField
        ParpoolButton               matlab.ui.control.StateButton
        DownsampleFactorSpinner     matlab.ui.control.Spinner
    end
    
    properties (Dependent, Access = public)
        OptimizerOptions struct
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
                algorithm = obj.AlgorithmDropdown.Value;
                opts.Algorithm = algorithm;
                s.OptimizerSettings.Algorithm = opts.Algorithm;

                maxFunEval = obj.MaxFunEvalEditField.Value;
                opts.MaxFunEvals = maxFunEval;
                s.OptimizerSettings.MaxFunEvals = maxFunEval;

                maxIter = obj.MaxIterEditField.Value;
                opts.MaxIter =  maxIter;
                s.OptimizerSettings.MaxIterations = maxIter;

                useParallel = logical(obj.ParpoolButton.Value);
                opts.UseParallel = useParallel;
                s.OptimizerSettings.UseParallel = useParallel;

                downsampleFactor = obj.DownsampleFactorSpinner.Value;
                s.DownsampleFactor = downsampleFactor;
            catch cause
                exception = exceptions.InvalidSolverOptions();
                exception = addCause(exception, cause);
                throw(exception)
            end
            e = events.FitterSettingsChangedEventData(opts);
            obj.OptimizerOptions = opts;
            notify(obj, 'SettingsChanged', e)
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 400 400];
            
            obj.Settings = settings.AppSettings();

            if isempty(obj.OptimizerOptions)
                opts = magicformula.v61.Fitter.initOptimizerOptions();
                obj.OptimizerOptions = opts;
            end
            
            g = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));
            obj.Panel = uipanel(g, ...
                'Title', 'Optimization Settings', ...
                'BorderType', 'none');
            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', repmat({20}, 1, 5), ...
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
            
            obj.MaxFunEvalEditField = uieditfield(obj.Grid, 'numeric', ...
                'Limits', [1 inf], ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'MaxFunEvals');
            
            obj.MaxIterEditField = uieditfield(obj.Grid, 'numeric', ...
                'Limits', [1 inf], ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'MaxIter');
            
            obj.ParpoolButton = uibutton(obj.Grid, 'state', ...
                'Text', 'Enable', ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'UseParallel');

            tooltip = 'Increase downsampling to reduce fit time.';
            obj.DownsampleFactorSpinner = uispinner(obj.Grid, ...
                'Limits', [1 1E5], ...
                'Tooltip', tooltip, ...
                'ValueChangedFcn', @obj.onSettingsChanged);
            uilabel(obj.Grid, 'Text', 'Downsampling', ...
                'Tooltip', tooltip);
        end
        function update(obj)
            s = obj.Settings.Fitter;
            opts = obj.OptimizerOptions;
            obj.AlgorithmDropdown.Value = opts.Algorithm;
            obj.MaxFunEvalEditField.Value = opts.MaxFunEvals;
            obj.MaxIterEditField.Value = opts.MaxIter;
            obj.ParpoolButton.Value = opts.UseParallel;
            obj.DownsampleFactorSpinner.Value = s.DownsampleFactor;
        end
    end
end
