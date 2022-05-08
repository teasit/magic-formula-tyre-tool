classdef ImageWithUploadButton < matlab.ui.componentcontainer.ComponentContainer
    %IMAGEWITHUPLOADBUTTON
    
    properties
        ImageSource char
    end
    
    events (HasCallbackProperty, NotifyAccess = protected)
        ImageSourceInvalid
        ImageChanged
    end
    
    properties (Access = private, Transient, NonCopyable)
        GridMain        matlab.ui.container.GridLayout
        Image           matlab.ui.control.Image
        UploadButton    matlab.ui.control.Button
    end
    
    methods (Access = public)
        function setImageSource(obj, value)
            if ~ischar(value)
                notify(obj, 'ImageSourceInvalid')
                return
            end
            obj.Image.ImageSource = value;
            notify(obj, 'ImageChanged');
        end
    end
    
    methods
        function value = get.ImageSource(obj)
            value = obj.Image.ImageSource;
        end
    end
    
    methods (Access = private)
        function getImageSource(obj)
            filter = {'*.jpg'; '*.png'; '*.gif'; '*.svg'};
            [file, path] = uigetfile(filter);
            if ~file
                return
            end
            obj.Image.ImageSource = [path, file];
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Position only used for standalone-testing.
            obj.Position = [0 0 600 300];
            
            obj.GridMain = uigridlayout(obj);
            obj.GridMain.RowHeight = {'fit', 22};
            obj.GridMain.ColumnWidth = {'1x'};
            
            obj.Image = uiimage(obj.GridMain);
            obj.Image.Layout.Row = 1;
            obj.Image.Layout.Column = 1;
            obj.Image.VerticalAlignment = 'top';
            
            obj.UploadButton = uibutton(obj.GridMain);
            obj.UploadButton.Layout.Row = 2;
            obj.UploadButton.Layout.Column = 1;
            obj.UploadButton.VerticalAlignment = 'top';
            obj.UploadButton.Text = 'Select Image';
            obj.UploadButton.ButtonPushedFcn = @(o,e) getImageSource(obj);
        end
        
        function update(obj)
        end
    end
    
    methods (Access=private)
    end
end
