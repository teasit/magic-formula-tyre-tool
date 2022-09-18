classdef FrictionEllipseAxes < matlab.ui.componentcontainer.ComponentContainer
    %FRICTIONELLIPSEAXES Axes to plot friction ellipse for tyre model.
    
    properties
        Model magicformula.Model = magicformula.v62.Model.empty
        Settings settings.AppSettings
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
            obj.Settings = settings.AppSettings();
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
            s = obj.Settings;
            s = s.View.TyreAnalysisPanel.TyrePlotFrictionEllipsePanel;
            
            ax = obj.Axes;
            cla(ax)
            
            if s.AxisEqual
                axis(ax, 'equal')
            else
                axis(ax, 'normal')
            end
            
            if s.AxisManualLimits
                limits = s.Limits;
                X = [-1, 1]*limits(1);
                Y = [-1, 1]*limits(2);
                xlim(ax,X)
                ylim(ax,Y)
            else
                xlim(ax,'auto')
                ylim(ax,'auto')
            end
            
            legend(ax, 'off')
            
            n = 200;
            marker = s.Marker;
            markerSize = s.MarkerSize;
            lineWidth = s.LineWidth;
            
            SA_max = s.SLIPANGL_Max;
            SA_step = s.SLIPANGL_Step;
            SA_sweep = deg2rad(linspace(-SA_max, SA_max, n));
            SA_const = deg2rad(-SA_max:SA_step:SA_max);
            
            SX_max = s.LONGSLIP_Max;
            SX_step = s.LONGSLIP_Step;
            SX_sweep = linspace(-SX_max, SX_max, n);
            SX_const = -SX_max:SX_step:SX_max;
            
            n_SA = numel(SA_const);
            n_SX = numel(SX_const);
            
            P = s.INFLPRES;
            FZ = s.FZW;
            IA = s.INCLANGL;
            TS = s.TYRESIDE;
            
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
            
            if s.LegendOn
                subset = [hSlipRatioSweeps hSlipAngleSweeps];
                labels = {
                    'SLIPANGL = const.'
                    'LONGSLIP = const.'};
                legend(ax, subset, labels, ...
                    'Location', 'bestoutside', ...
                    'Orientation', 'horizontal')
            end
        end
    end
end
