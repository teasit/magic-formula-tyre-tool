classdef TyrePropertiesEditor < matlab.ui.componentcontainer.ComponentContainer
    %TYREPROPERTIESEDITOR
    
    properties
        Tyre Tyre
        TyreImagePath char = 'tyres/Hoosier_43075_LCO_7/43075_top.jpg'
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridMain                    matlab.ui.container.GridLayout
        GridFields                  matlab.ui.container.GridLayout
        NameEditField               matlab.ui.control.EditField
        NameEditFieldLabel          matlab.ui.control.Label
        ManufacturerEditField       matlab.ui.control.EditField
        ManufacturerEditFieldLabel  matlab.ui.control.Label
        PartnumberEditField         matlab.ui.control.EditField
        PartnumberEditFieldLabel    matlab.ui.control.Label
        TyreTypeDropDown            matlab.ui.control.DropDown
        TyreTypeDropDownLabel       matlab.ui.control.Label
        TyreImageComponent          ui.ImageWithUploadButton
    end
    
    methods (Access=protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 1000 400];
            
            obj.GridMain = uigridlayout(obj);
            obj.GridMain.RowHeight = {'1x'};
            obj.GridMain.ColumnWidth = {'2x',200};
            obj.GridMain.ColumnSpacing = 10;
            
            obj.GridFields = uigridlayout(obj.GridMain);
            obj.GridFields.RowHeight = {22,22,22,22,'1x'};
            obj.GridFields.ColumnWidth = {'fit','1x'};
            obj.GridFields.Layout.Column = 1;
            
            obj.NameEditField = uieditfield(obj.GridFields);
            obj.NameEditField.Layout.Row = 1;
            obj.NameEditField.Layout.Column = 2;
            obj.NameEditFieldLabel = uilabel(obj.GridFields);
            obj.NameEditFieldLabel.Layout.Row = 1;
            obj.NameEditFieldLabel.Layout.Column = 1;
            obj.NameEditFieldLabel.Text = 'Name';
            
            obj.ManufacturerEditField = uieditfield(obj.GridFields);
            obj.ManufacturerEditField.Layout.Row = 2;
            obj.ManufacturerEditField.Layout.Column = 2;
            obj.ManufacturerEditFieldLabel = uilabel(obj.GridFields);
            obj.ManufacturerEditFieldLabel.Layout.Row = 2;
            obj.ManufacturerEditFieldLabel.Layout.Column = 1;
            obj.ManufacturerEditFieldLabel.Text = 'Manufacturer';
            
            obj.PartnumberEditField = uieditfield(obj.GridFields);
            obj.PartnumberEditField.Layout.Row = 3;
            obj.PartnumberEditField.Layout.Column = 2;
            obj.PartnumberEditFieldLabel = uilabel(obj.GridFields);
            obj.PartnumberEditFieldLabel.Layout.Row = 3;
            obj.PartnumberEditFieldLabel.Layout.Column = 1;
            obj.PartnumberEditFieldLabel.Text = 'ID';
            
            obj.TyreTypeDropDown = uidropdown(obj.GridFields);
            obj.TyreTypeDropDown.Layout.Row = 4;
            obj.TyreTypeDropDown.Layout.Column = 2;
            obj.TyreTypeDropDown.Items = {'Slicks', 'Wet'};
            obj.TyreTypeDropDownLabel = uilabel(obj.GridFields);
            obj.TyreTypeDropDownLabel.Layout.Row = 4;
            obj.TyreTypeDropDownLabel.Layout.Column = 1;
            obj.TyreTypeDropDownLabel.Text = 'Type';
            
            obj.TyreImageComponent = ui.ImageWithUploadButton(obj.GridMain);
            obj.TyreImageComponent.Layout.Column = 2;
            obj.TyreImageComponent.setImageSource(obj.TyreImagePath);
        end
        
        function update(obj)
        end
    end
    
    methods (Access=private)
    end
end
