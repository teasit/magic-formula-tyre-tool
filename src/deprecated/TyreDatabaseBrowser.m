classdef TyreDatabaseBrowser < matlab.ui.componentcontainer.ComponentContainer
    %TYREDATABASEBROWSER Lists all added tyres in a tabular view
    
    properties
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        RemoveTyreRequest %RemoveTyreRequestFcn
        OpenTyreRequest %OpenTyreRequestFcn
        AddTyreRequest %NewTyreRequestFcn
    end
    
    properties (Access = private, Transient, NonCopyable)
        Grid                matlab.ui.container.GridLayout 
        TyreTable           matlab.ui.control.Table
        RemoveTyreButton    matlab.ui.control.Button
        OpenTyreButton      matlab.ui.control.Button
        AddTyreButton       matlab.ui.control.Button
    end
    
    methods (Access=protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 400 300];
            
            obj.Grid = uigridlayout(obj);
            obj.Grid.RowHeight = {'1x', 22};
            obj.Grid.ColumnWidth = {'1x', '1x', '1x'};
            obj.Grid.ColumnSpacing = 10;
            obj.Grid.Padding = 0*ones(1,4);
            
            obj.TyreTable = uitable(obj.Grid);
            obj.TyreTable.Layout.Row = 1;
            obj.TyreTable.Layout.Column = [1 3];
            obj.TyreTable.ColumnName = {
                'Manufacturer';
                'ID';
                'Diameter';
                'Type'};
            obj.TyreTable.RowName = {};
            obj.TyreTable.ColumnWidth = 'auto';
            obj.TyreTable.ColumnSortable = true;
            obj.TyreTable.ColumnEditable = false(1,3);
            obj.TyreTable.CellSelectionCallback = ...
                @(~,event) onCellSelection(obj, event);
            obj.TyreTable.Data = {
                'Hoosier',      'XXXXX', '16"', 'Slicks';
                'Continental',  'XXXX',  '18"', 'Slicks';
                };
            
            obj.AddTyreButton = uibutton(obj.Grid, 'push');
            obj.AddTyreButton.Layout.Row = 2;
            obj.AddTyreButton.Layout.Column = 1;
            obj.AddTyreButton.Text = 'Add Tyre';
            obj.AddTyreButton.ButtonPushedFcn = ...
                @(~,~) notify(obj, 'AddTyreRequest');

            obj.OpenTyreButton = uibutton(obj.Grid, 'push');
            obj.OpenTyreButton.Layout.Row = 2;
            obj.OpenTyreButton.Layout.Column = 2;
            obj.OpenTyreButton.Enable = 'off';
            obj.OpenTyreButton.Text = 'Open Tyre';
            obj.OpenTyreButton.ButtonPushedFcn = ...
                @(~,~) notify(obj, 'OpenTyreRequest');
            
            obj.RemoveTyreButton = uibutton(obj.Grid, 'push');
            obj.RemoveTyreButton.Layout.Row = 2;
            obj.RemoveTyreButton.Layout.Column = 3;
            obj.RemoveTyreButton.Enable = 'off';
            obj.RemoveTyreButton.Text = 'Remove Tyre';
            obj.RemoveTyreButton.ButtonPushedFcn = ...
                @(~,~) notify(obj, 'RemoveTyreRequest');
        end
        
        function update(obj)
        end
    end
    
    methods (Access=private)
        function onCellSelection(obj, event)
            indices = event.Indices;
            
            numberRows = size(indices,1);
            singleRow = numberRows == 1;
            multipleRows = numberRows > 1;
            
            obj.RemoveTyreButton.Enable = singleRow || multipleRows;
            obj.OpenTyreButton.Enable = singleRow;
        end
    end
end
