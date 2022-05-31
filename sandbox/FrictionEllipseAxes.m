classdef FrictionEllipseAxes < matlab.ui.componentcontainer.ComponentContainer
    %FRICTIONELLIPSEAXES Axes to plot friction ellipse for tyre model.
    
    properties
        TyreModel mftyre.Model = mftyre.v62.Model.empty
    end
    properties (Access = private, Transient, NonCopyable)
        Grid matlab.ui.container.GridLayout
        Axes matlab.ui.control.UIAxes
    end
    events (HasCallbackProperty, NotifyAccess = protected)
    end
    methods (Access = protected)
        function setup(obj)
            obj.Position = [0 0 800 400];
            obj.Grid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x'}, ...
                'Padding', zeros(1,4));
            setupAxes(obj)
        end
        function setupAxes(obj)
            ax = uiaxes(obj.Grid);
            grid(ax, 'on')
            hold(ax, 'on')
            axis(ax,'equal')
            obj.Axes = ax;
        end
        function update(obj)
            model = obj.TyreModel;
            if isempty(model)
                return
            end
            ax = obj.Axes;
            cla(ax)

            slipangl = deg2rad(-15:1:15);
            for i = 1:numel(slipangl)
                SA = slipangl(i);
                SX = linspace(-1,1);
                IA = deg2rad(0);
                P = 80E3;
                FZ = 1000;
                [FX,FY] = model.eval(SA,SX,IA,P,FZ,0);
                plot(ax, FX, FY, 'r-')
            end
            
            longslip = -0.2:0.005:0.2;
            for i = 1:numel(longslip)
                SA = deg2rad(linspace(-30, 30));
                SX = longslip(i);
                IA = deg2rad(0);
                P = 80E3;
                FZ = 1000;
                [FX,FY] = model.eval(SA,SX,IA,P,FZ,0);
                plot(ax, FX, FY, 'b-')
            end
        end
    end
end
