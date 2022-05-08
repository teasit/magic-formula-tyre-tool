classdef TyreFitterFittingModesPanel < matlab.ui.componentcontainer.ComponentContainer
    %FitterFITTINGMODESPANEL Panel to configure fitting modes for MFTyre fitter.
    
    properties
        FitModes mftyre.v62.FitMode
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        SelectionChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid                matlab.ui.container.GridLayout
        Checkboxes          matlab.ui.control.CheckBox
        Panel               matlab.ui.container.Panel
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
            evntdata = events.FittingModesChangedEventData(obj.FitModes);
            notify(obj, 'SelectionChanged', evntdata)
        end
    end
    
    methods (Access = protected)
        function setupGrid(obj)
            obj.Grid = uigridlayout(obj.Panel, ...
                'RowHeight', repmat({'fit'}, 1, 3), ...
                'ColumnWidth', repmat({'1x'}, 1, 3), ...
                'ColumnSpacing', 5, ...
                'Padding', zeros(1,4));
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
            obj.Panel = uipanel(obj, 'BorderType', 'none');
            setupGrid(obj)
            setupCheckboxes(obj)
        end
        function updateCheckboxes(obj)
            checkboxes = obj.Checkboxes;
            set(checkboxes, 'Value', false)
            fitmodes = enumeration('mftyre.v62.FitMode');
            fitmodesSelected = obj.FitModes;
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
