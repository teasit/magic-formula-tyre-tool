classdef NumericRangeSelector < matlab.ui.componentcontainer.ComponentContainer
    %NUMERICRANGESELECTOR Provides two inputs for user to specify range.
    
    properties
        Range (1,2) double = [0 1]
        RangeLimits (1,2) double = [-inf inf]
        DisplayDecimals double {isinteger} = 2
        Unit char = '1'
    end
    properties (Access = private, Transient, NonCopyable)
        LabelUnit matlab.ui.control.Label
        EditFieldRange (2,1) matlab.ui.control.NumericEditField
    end
    events (HasCallbackProperty, NotifyAccess = protected)
        RangeChanged
    end
    methods (Access = private)
        function onEditFieldChanged(obj, ~, ~)
            rangeNew = zeros(1,2);
            rangeNew(1) = obj.EditFieldRange(1).Value;
            rangeNew(2) = obj.EditFieldRange(2).Value;
            
            isIncreasing = rangeNew(2) >= rangeNew(1);
            if ~isIncreasing
                set(obj.EditFieldRange(1), 'Value', obj.Range(1))
                set(obj.EditFieldRange(2), 'Value', obj.Range(2))
                return
            end
            
            obj.Range = rangeNew;
            
            e = events.RangeChanged(rangeNew);
            notify(obj, 'RangeChanged', e)
        end
    end
    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 400 50];
            
            g = uigridlayout(obj, ...
                'RowHeight', repmat({'1x'}, 1, 2), ...
                'ColumnWidth', repmat({'1x'}, 1, 1), ...
                'RowSpacing', 5, ...
                'Padding', zeros(1,4));
            
            edtRange(1) = uieditfield(g, 'numeric');
            
            edtRange(2) = uieditfield(g, 'numeric');
            
            set(edtRange, 'ValueChangedFcn', @obj.onEditFieldChanged)
            set(edtRange, 'Limits', obj.RangeLimits)
            obj.EditFieldRange = edtRange;
        end
        function update(obj)
            set(obj.EditFieldRange, 'Limits', obj.RangeLimits)
            set(obj.EditFieldRange(1), 'Value', obj.Range(1))
            set(obj.EditFieldRange(2), 'Value', obj.Range(2))
            if ~isempty(obj.Unit)
                unit = sprintf(' [%s]', obj.Unit);
            else
                unit = char.empty;
            end
            decimals = num2str(obj.DisplayDecimals);
            format = ['%.' decimals 'f' unit];
            set(obj.EditFieldRange, 'ValueDisplayFormat', format)
        end
    end
end
