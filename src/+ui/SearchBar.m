classdef SearchBar < matlab.ui.componentcontainer.ComponentContainer
    %SEARCHBAR Search bar ui component.
    
    properties
        Text char = char.empty
        IconPrev char = fullfile('assets', 'icons', 'fontawesome', ...
            'angle-up-solid.svg')
        IconNext char = fullfile('assets', 'icons', 'fontawesome', ...
            'angle-down-solid.svg')
        IconSearch char = fullfile('assets', 'icons', 'fontawesome', ...
            'magnifying-glass-solid.svg')
        IconClose char = fullfile('assets', 'icons', 'fontawesome', ...
            'xmark-solid.svg')
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid matlab.ui.container.GridLayout
        EditField matlab.ui.control.EditField
        PrevButton matlab.ui.control.Button
        NextButton matlab.ui.control.Button
        SearchButton matlab.ui.control.Button
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        SearchTextChanged
        SearchPrevRequested
        SearchNextRequested
    end
    
    events (NotifyAccess = public)
        SearchResultsAvailable
    end
    
    methods (Access = protected)
        function setup(obj)
            obj.Position = [5 5 500 22];
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x', 25, 25, 25}, ...
                'ColumnSpacing', 5, ...
                'Padding', zeros(1,4));
            obj.EditField = uieditfield(obj.Grid, ...
                'ValueChangedFcn', @obj.onSearchTextChanged, ...
                'ValueChangingFcn', @obj.onSearchTextChanging);
            obj.PrevButton = uibutton(obj.Grid, ...
                'Enable', false, ...
                'Text', char.empty, ...
                'Icon', obj.IconPrev, ...
                'ButtonPushedFcn', @(~,~) notify(obj, 'SearchPrevRequested'));
            obj.NextButton = uibutton(obj.Grid, ...
                'Enable', false, ...
                'Text', char.empty, ...
                'Icon', obj.IconNext, ...
                'ButtonPushedFcn', @(~,~) notify(obj, 'SearchNextRequested'));
            obj.SearchButton = uibutton(obj.Grid, ...
                'Text', char.empty, ...
                'Icon', obj.IconSearch, ...
                'IconAlignment', 'left', ...
                'ButtonPushedFcn', @obj.onSearchButtonPressed);
            
            addlistener(obj, 'SearchResultsAvailable', ...
                @obj.onSearchResultsAvailable);
        end
        function update(obj)
            % set(obj.EditField, 'Value', obj.Text)
            
            text = obj.Text;
            if isempty(text)
                set(obj.SearchButton, 'Icon', obj.IconSearch)
            else
                set(obj.SearchButton, 'Icon', obj.IconClose)
            end
        end
    end
    methods (Access = private)
        function onSearchButtonPressed(obj, ~, ~)
            text = obj.Text;
            if ~isempty(text)
                text = char.empty;
                obj.Text = text;
                set(obj.EditField, 'Value', text)
                e = events.SearchTextChanged(text);
                notify(obj, 'SearchTextChanged', e)
            end
        end
        function onSearchResultsAvailable(obj, ~, e)
            indices = e.SearchIndices;
            matches = size(indices, 1);
            enable = matches > 1;
            set([obj.PrevButton obj.NextButton], 'Enable', enable)
        end
        function onSearchTextChanged(obj, ~, event)
            text = event.Value;
            obj.Text = text;
            e = events.SearchTextChanged(text);
            notify(obj, 'SearchTextChanged', e)
        end
        function onSearchTextChanging(obj, ~, event)
            text = event.Value;
            obj.Text = text;
        end
    end
end
