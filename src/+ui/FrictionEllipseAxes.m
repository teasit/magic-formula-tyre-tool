classdef FrictionEllipseAxes < matlab.ui.componentcontainer.ComponentContainer
    %FRICTIONELLIPSEAXES Axes to plot friction ellipse for tyre model.
    
    properties
        Model mftyre.Model = mftyre.v62.Model.empty
    end
    properties
        SLIPANGL_Max double = 15
        SLIPANGL_Step double = 3
        LONGSLIP_Max double = 0.15
        LONGSLIP_Step double = 0.01
        INFLPRES double = 80E3
        INCLANGL double = 0
        FZW double = 1E3
        TYRESIDE double = 0
    end
    properties
        Limits double = [5000 5000]
    end
    properties
        AxisEqual logical = true
        AxisManualLimits logical = true
        LegendOn logical = true
        Marker char = 'none'
        MarkerSize double = 10
        LineWidth double = 1
    end
    properties (Access = private, Transient, NonCopyable)
        Grid matlab.ui.container.GridLayout
        Axes matlab.ui.control.UIAxes
    end
    events (HasCallbackProperty, NotifyAccess = protected)
    end
    methods
        function refresh(obj)
            updateAxes(obj)
        end
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
            xlabel(ax, 'FY / N')
            ylabel(ax, 'FX / N')
            obj.Axes = ax;
        end
        function update(obj)
            model = obj.Model;
            if isempty(model)
                return
            end
            updateAxes(obj)
        end
        function updateAxes(obj)
            model = obj.Model;
            
            ax = obj.Axes;
            cla(ax)
            
            if obj.AxisEqual
                axis(ax, 'equal')
            else
                axis(ax, 'normal')
            end
            
            if obj.AxisManualLimits
                limits = obj.Limits;
                X = [-1, 1]*limits(1);
                Y = [-1, 1]*limits(2);
                xlim(X)
                ylim(Y)
            else
                xlim('auto')
                ylim('auto')
            end
            
            legend off
            
            n = 200;
            marker = obj.Marker;
            markerSize = obj.MarkerSize;
            lineWidth = obj.LineWidth;
            
            SA_max = obj.SLIPANGL_Max;
            SA_step = obj.SLIPANGL_Step;
            SA_sweep = deg2rad(linspace(-SA_max, SA_max, n));
            SA_const = deg2rad(-SA_max:SA_step:SA_max);
            
            SX_max = obj.LONGSLIP_Max;
            SX_step = obj.LONGSLIP_Step;
            SX_sweep = linspace(-SX_max, SX_max, n);
            SX_const = -SX_max:SX_step:SX_max;
            
            n_SA = numel(SA_const);
            n_SX = numel(SX_const);
            
            P = obj.INFLPRES;
            FZ = obj.FZW;
            IA = obj.INCLANGL;
            TS = obj.TYRESIDE;
            
            colors = get(ax, 'colororder');
            
            h = gobjects(n_SA, 1);
            for i = 1:n_SA
                SA = SA_const(i);
                SX = SX_sweep;
                [FX,FY] = model.eval(SA,SX,IA,P,FZ,TS);                
                h(i) = plot(ax, FY, FX, 'k-', 'LineWidth', lineWidth, ...
                    'Marker', marker, 'MarkerSize', markerSize, ...
                    'Color', colors(1,:));
                SA = rad2deg(SA)*ones(1,n);
                SX = SX*100;
                h(i).DataTipTemplate.DataTipRows = [
                    dataTipTextRow('\alpha', SA, '%.1f deg')
                    dataTipTextRow('S_X', SX, '%.1f %%')
                    ];
            end
            hSlipRatioSweeps = h(end);

            h = gobjects(n_SX, 1);
            for j = 1:n_SX
                SA = SA_sweep;
                SX = SX_const(j);
                [FX,FY] = model.eval(SA,SX,IA,P,FZ,TS);
                h(j) = plot(ax, FY, FX, 'k-', 'LineWidth', lineWidth, ...
                    'Marker', marker, 'MarkerSize', markerSize, ...
                    'Color', colors(2,:));
                SA = rad2deg(SA);
                SX = SX*100*ones(1,n);
                h(j).DataTipTemplate.DataTipRows = [
                    dataTipTextRow('\alpha', SA, '%.1f deg')
                    dataTipTextRow('S_X', SX, '%.1f %%')
                    ];
            end
            hSlipAngleSweeps = h(end);
            
            if obj.LegendOn
                subset = [hSlipRatioSweeps hSlipAngleSweeps];
                labels = {
                    'SLIPANGL = const.'
                    'LONGSLIP = const.'};
                legend(subset, labels, ...
                    'Location', 'bestoutside', ...
                    'Orientation', 'horizontal')
            end
        end
    end
end
