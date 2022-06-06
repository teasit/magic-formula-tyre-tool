classdef TyreFitterFittingModesPanel < matlab.ui.componentcontainer.ComponentContainer
    %FitterFITTINGMODESPANEL Panel to configure fitting modes for MFTyre fitter.
    
    properties (SetAccess = protected)
        FitModes mftyre.v62.FitMode
    end
    
    properties (Access = private)
        Settings settings.AppSettings
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        SelectionChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        Panel               matlab.ui.container.Panel
        Grid                matlab.ui.container.GridLayout
        Checkboxes          matlab.ui.control.CheckBox
    end
    
    methods (Access = private)
        function onCheckboxValueChanged(obj, origin, event)
            [fitmodes, fitmodesText] = enumeration('mftyre.v62.FitMode');
            checkboxText = origin.Text;
            I = strcmp(fitmodesText, checkboxText);
            fitmode = fitmodes(I);
            
            enable = event.Value;
            if enable
                fitModesSelected = obj.FitModes;
                fitModesSelected = [fitModesSelected fitmode];
                fitModesSelected = unique(fitModesSelected);
                obj.FitModes = fitModesSelected;
            else
                fitModesSelected = obj.FitModes;
                I = fitModesSelected == fitmode;
                fitModesSelected(I) = [];
                obj.FitModes = fitModesSelected;
            end
            
            obj.Settings.Fitter.FitModes = fitModesSelected;
            
            e = events.FittingModesChangedEventData(obj.FitModes);
            notify(obj, 'SelectionChanged', e)
        end
    end
    
    methods (Access = protected)
        function setupGrid(obj)
            g = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));
            obj.Panel = uipanel(g, ...
                'Title', 'Fit-Modes', ...
                'BorderType', 'none');
            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', repmat({'fit'}, 1, 3), ...
                'ColumnWidth', repmat({'1x'}, 1, 3), ...
                'ColumnSpacing', 5, ...
                'Padding', 5*ones(1,4));
        end
        function setupCheckboxes(obj)
            import mftyre.v62.FitMode
            [~, fitmodes] = enumeration('mftyre.v62.FitMode');
            for i = 1:numel(fitmodes)
                cb = uicheckbox(obj.Grid, ...
                    'Text', fitmodes{i}, ...
                    'ValueChangedFcn', @obj.onCheckboxValueChanged);
                if any(strcmp(fitmodes{i}, {'Fz', 'Mz', 'Mz0', 'Mx', 'My'}))
                    % todo: enable these fitmodes after they are
                    % implemented in the Fitter class.
                    cb.Enable = false;
                end
                obj.Checkboxes = [obj.Checkboxes cb];
            end
        end
        function setup(obj)
            obj.Position = [0 0 500 150]; % for testing
            obj.Settings = settings.AppSettings();
            setupGrid(obj)
            setupCheckboxes(obj)
            obj.FitModes = obj.Settings.Fitter.FitModes;
            addlistener(obj.Settings.Fitter, 'SettingsChanged', ...
                @(~,~) update(obj));
        end
        function updateCheckboxes(obj)
            checkboxes = obj.Checkboxes;
            set(checkboxes, 'Value', false)
            fitmodes = enumeration('mftyre.v62.FitMode');
            fitmodesSelected = obj.Settings.Fitter.FitModes;
            for i = 1:numel(fitmodesSelected)
                fitmode = fitmodesSelected(i);
                I = fitmodes == fitmode;
                checkbox = checkboxes(I);
                set(checkbox, 'Value', true)
            end
        end
        function update(obj)
            updateCheckboxes(obj)
        end
    end
end
