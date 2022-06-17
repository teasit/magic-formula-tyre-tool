classdef TyreFitterPanel < matlab.ui.componentcontainer.ComponentContainer
    %TyreFitterPanel Provides GUI to configure and run Fitter.
    
    events (HasCallbackProperty, NotifyAccess = protected)
        FitterStartRequested
        FitterFittingModesChanged
        FitterSolverSettingsChanged
    end
    
    events (NotifyAccess = public)
        TyreFitterModesChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid                        matlab.ui.container.GridLayout
        MainGrid                    matlab.ui.container.GridLayout
        Panel                       matlab.ui.container.Panel
        FittingModesPanel           ui.TyreFitterFittingModesPanel
        SolverSettingsPanel         ui.TyreFitterSolverSettingsPanel
        RunStateButton              matlab.ui.control.Button
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
        function onTyreFitterModesChanged(obj, ~, event)
            fitmodes = event.FitModes;
            obj.FittingModesPanel.FitModes = fitmodes;
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 400 400];
            
            obj.MainGrid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));

            obj.Panel = uipanel(obj.MainGrid);

            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', {'fit', 'fit', 'fit'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4), ...
                'ColumnSpacing', 10);
            
            obj.FittingModesPanel = ui.TyreFitterFittingModesPanel(obj.Grid, ...
                'SelectionChangedFcn', @obj.onFittingModesChanged);
            
            obj.SolverSettingsPanel = ui.TyreFitterSolverSettingsPanel(obj.Grid, ...
                'SettingsChangedFcn', @obj.onSolverSettingsChanged);
            
            g = uigridlayout(obj.Grid, ...
                'RowHeight', {20}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', 5*ones(1,4));
            obj.RunStateButton = uibutton(g, ...
                'Text', 'Start Fitter', ...
                'Icon', 'play-solid.svg', ...
                'ButtonPushedFcn', @obj.onRunStateButtonValueChanged);
        
            addlistener(obj, 'TyreFitterModesChanged', ...
                @obj.onTyreFitterModesChanged);
        end
        function update(obj)
        end
    end
end
