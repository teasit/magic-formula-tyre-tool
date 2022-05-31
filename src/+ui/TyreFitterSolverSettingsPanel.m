classdef TyreFitterSolverSettingsPanel < matlab.ui.componentcontainer.ComponentContainer
    %FITTERSOLVERSETTINGSPANEL Panel to configure optimization settings of
    %fitter (fmincon).
    
    events (HasCallbackProperty, NotifyAccess = protected)
        SettingsChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid                        matlab.ui.container.GridLayout
        AlgorithmDropdown           matlab.ui.control.DropDown
        MaxFunEvalEditField         matlab.ui.control.EditField
        MaxIterEditField            matlab.ui.control.EditField
        ParpoolButton               matlab.ui.control.StateButton
    end
    
    properties (Access = public)
        Settings optim.options.Fmincon = optimoptions('fmincon')
    end
    
    methods (Access = private)
        function onSettingsChanged(obj, ~, ~)
            settings = obj.Settings;
            try
                settings.Algorithm = ...
                    obj.AlgorithmDropdown.Value;
                settings.MaxFunctionEvaluations = str2double(...
                    obj.MaxFunEvalEditField.Value);
                settings.MaxIterations =  str2double(...
                    obj.MaxIterEditField.Value);
                settings.UseParallel = logical(...
                    obj.ParpoolButton.Value);
            catch cause
                exception = exceptions.InvalidSolverOptions();
                exception = addCause(exception, cause);
                throw(exception)
            end
            evntdata = events.FitterSettingsChangedEventData(settings);
            obj.Settings = settings;
            notify(obj, 'SettingsChanged', evntdata)
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 1000 500];
            
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', repmat({20}, 1, 4), ...
                'ColumnWidth', repmat({'fit'}, 1, 2), ...
                'Padding', zeros(1,4), ...
                'ColumnSpacing', 10);
            
            solverOptions = {
                'interior-point'
                'trust-region-reflective'
                'sqp'
                'active-set'
                };
            obj.AlgorithmDropdown = uidropdown(obj.Grid, ...
                'Items', solverOptions, ...
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
            s = obj.Settings;
            obj.AlgorithmDropdown.Value = s.Algorithm;
            obj.MaxFunEvalEditField.Value = num2str(s.MaxFunctionEvaluations);
            obj.MaxIterEditField.Value = num2str(s.MaxIterations);
            obj.ParpoolButton.Value = s.UseParallel;
        end
    end
end
