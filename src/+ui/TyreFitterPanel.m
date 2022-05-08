classdef TyreFitterPanel < matlab.ui.componentcontainer.ComponentContainer
    %TyreFitterPanel Provides GUI to configure and run MFTyre Fitter.
    
    events (HasCallbackProperty, NotifyAccess = protected)
        FitterStartRequested
        FitterFittingModesChanged
        FitterSolverSettingsChanged
    end
    
    events (NotifyAccess = public)
        FitterStarted
        FitterCanceled
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid                        matlab.ui.container.GridLayout
        Panel                       matlab.ui.container.Panel
        FittingModesPanel           ui.TyreFitterFittingModesPanel
        SolverSettingsPanel         ui.TyreFitterSolverSettingsPanel
        RunStateButton              matlab.ui.control.Button
    end
    
    properties (Dependent, Access = public)
        Settings optim.options.Fmincon
    end
    
    properties (Constant, Access = protected)
        PanelTitle char = 'Fitter Settings'
    end
    
    methods (Access = private)
        function onFittingModesChanged(obj, ~, event)
            modes = event.FitModes;
            evntdata = events.FittingModesChangedEventData(modes);
            notify(obj, 'FitterFittingModesChanged', evntdata)
        end
        function onSolverSettingsChanged(obj, ~, event)
            settings = event.Settings;
            evntdata = events.FitterSettingsChangedEventData(settings);
            notify(obj, 'FitterSolverSettingsChanged', evntdata)
        end
        function onRunStateButtonValueChanged(obj, ~, ~)
            notify(obj, 'FitterStartRequested')
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 400 400];
            
            obj.Panel = uipanel(obj, ...
                'BorderType', 'none', ...
                'Title', obj.PanelTitle);
            
            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', {80, 120, 'fit'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', 5*ones(1,4), ...
                'ColumnSpacing', 10);
            
            obj.FittingModesPanel = ui.TyreFitterFittingModesPanel(obj.Grid, ...
                'SelectionChangedFcn', @obj.onFittingModesChanged);
            
            obj.SolverSettingsPanel = ui.TyreFitterSolverSettingsPanel(obj.Grid, ...
                'SettingsChangedFcn', @obj.onSolverSettingsChanged);
            
            obj.RunStateButton = uibutton(obj.Grid, ...
                'Text', 'Start Fitter', ...
                'Icon', 'play-solid.svg', ...
                'ButtonPushedFcn', @obj.onRunStateButtonValueChanged);
        end
        function update(obj)
        end
    end
end
