classdef TyrePlotFrictionEllipsePanel < matlab.ui.componentcontainer.ComponentContainer
    %TYREPLOTFRICTIONELLIPSEPANEL Plots friction ellipse of tyre model.
    
    properties
        Model mftyre.v62.Model = mftyre.v62.Model.empty
        ShowSidebar logical = true
    end
    properties (Access = private, Transient, NonCopyable)
        MainGrid                    matlab.ui.container.GridLayout
        Axes                        ui.FrictionEllipseAxes
        SidePanel                   matlab.ui.container.Panel
        SidePanelGrid               matlab.ui.container.GridLayout
    end
    events (NotifyAccess = public)
        TyreModelChanged
        TyreDataChanged
    end
    methods (Access = private)
        function onModelChanged(obj, ~, event)
            model = event.Model;
            obj.Model = model;
            obj.Axes.Model = model;
        end
        function onPlotSettingsChanged(obj, source, event)
            ax = obj.Axes;
            tag = source.Tag;
            switch tag
                case 'AxisEqual'
                    value = event.Value;
                    ax.AxisEqual = value;
                case 'AxisManualLimits'
                    value = event.Value;
                    ax.AxisManualLimits = value;
                case 'XLimit'
                    value = event.Value;
                    ax.Limits(1) = value;
                case 'YLimit'
                    value = event.Value;
                    ax.Limits(2) = value;
                case 'Legend'
                    value = event.Value;
                    ax.LegendOn = value;
                case 'Marker'
                    value = event.Value;
                    ax.Marker = value;
                case 'MarkerSize'
                    value = event.Value;
                    ax.MarkerSize = value;
                case 'LineWidth'
                    value = event.Value;
                    ax.LineWidth = value;
                case 'MaxLONGSLIP'
                    value = event.Value;
                    value = value/100;
                    ax.LONGSLIP_Max = value;
                case 'MaxSLIPANGL'
                    value = event.Value;
                    ax.SLIPANGL_Max = value;
                case 'StepLONGSLIP'
                    value = event.Value;
                    value = value/100;
                    ax.LONGSLIP_Step = value;
                case 'StepSLIPANGL'
                    value = event.Value;
                    ax.SLIPANGL_Step = value;
            end
        end
        function onSteadyStateSettingsChanged(obj, source, event)
            ax = obj.Axes;
            tag = source.Tag;
            value = event.Value;
            switch tag
                case 'INFLPRES'
                    bar2pascal = @(x) x*1E5;
                    ax.INFLPRES = bar2pascal(value);
                case 'INCLANGL'
                    ax.INCLANGL = deg2rad(value);
                case 'FZW'
                    ax.FZW = value;
                case 'TYRESIDE'
                    ax.TYRESIDE = value;
            end
        end
    end
    methods(Access = protected)
        function updateSidebarState(obj)
            show = obj.ShowSidebar;
            sidebar = obj.SidePanel;
            axes = obj.Axes;
            if show
                set(sidebar, 'Visible', 'on')
                axes.Layout.Column = 1;
            else
                set(sidebar, 'Visible', 'off')
                axes.Layout.Column = [1 2];
            end
        end
    end
    methods(Access = protected)
        function setupMainGrid(obj)
            obj.MainGrid = uigridlayout(obj, ...
                'RowHeight', {'1x'}, ...
                'ColumnWidth', {'1x', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 0*ones(1,4), ...
                'Scrollable', false);
        end
        function setupSidePanel(obj)
            obj.SidePanel = uipanel(obj.MainGrid);
            obj.SidePanel.Layout.Column = 2;
            
            obj.SidePanelGrid = uigridlayout(obj.SidePanel, ...
                'RowHeight', repmat({'fit'}, 1, 2), ...
                'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, ...
                'Padding', zeros(1,4), ...
                'Scrollable', true);
        end
        function setupPlotSettings(obj)
            p = uipanel(obj.SidePanelGrid, ...
                'Title', 'Plot Settings', ...
                'BorderType', 'none');
            g = uigridlayout(p, ...
                'RowHeight', repmat({'fit'}, 1, 9), ...
                'ColumnWidth', {'fit', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 10*ones(1,4), ...
                'Scrollable', false);
            
%             uilabel(g, 'Text', 'Legend');
%             uibutton(g, 'state', 'Text', 'On', 'Enable', 'off', ...
%                 'ValueChangedFcn', @obj.onPlotSettingsChanged, ...
%                 'Tag', 'Legend');
%             
%             uilabel(g, 'Text', 'Hold');
%             uibutton(g, 'state', 'Text', 'On', 'Enable', 'off');
            
            uilabel(g, 'Text', 'Axis');
            uibutton(g, 'state', 'Text', 'Equal', 'Value', true, ...
                'Tag', 'AxisEqual', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'Limits');
            uibutton(g, 'state', 'Text', 'Manual', 'Value', true, ...
                'Tag', 'AxisManualLimits', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
           
            uilabel(g, 'Text', 'X-Limit');
            uieditfield(g, 'numeric', 'Value', 4000, ...
                'Tag', 'XLimit', ...
                'ValueDisplayFormat', '%.0f [N]', ...
                'Limits', [0 100E3], 'LowerLimitInclusive', false, ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'Y-Limit');
            uieditfield(g, 'numeric', 'Value', 4000, ...
                'Tag', 'YLimit', ...
                'ValueDisplayFormat', '%.0f [N]', ...
                'Limits', [0 100E3], 'LowerLimitInclusive', false, ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'SLIPANGL (Max)');
            uieditfield(g, 'numeric', 'Value', 15, ...
                'Tag', 'MaxSLIPANGL', ...
                'Limits', [-90 90], ...
                'ValueDisplayFormat', '%.1f [deg]', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'SLIPANGL (Step)');
            uieditfield(g, 'numeric', 'Value', 1, ...
                'Tag', 'StepSLIPANGL', ...
                'Limits', [-90 90], ...
                'ValueDisplayFormat', '%.1f [deg]', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'LONGSLIP (Max)');
            uieditfield(g, 'numeric', 'Value', 15, ...
                'Tag', 'MaxLONGSLIP', ...
                'Limits', [-1 1]*100, ...
                'ValueDisplayFormat', '%.1f [%%]', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            
            uilabel(g, 'Text', 'LONGSLIP (Step)');
            uieditfield(g, 'numeric', 'Value', 1, ...
                'Tag', 'StepLONGSLIP', ...
                'Limits', [-1 1]*100, ...
                'ValueDisplayFormat', '%.1f [%%]', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged);
            
            uilabel(g, 'Text', 'Marker');
            markers = {'none', '.', '+', 'o', '*', 'x', 'square', ...
                'diamond', '^', 'v', '>', '<', 'pentagram', 'hexagram'};
            uidropdown(g, 'Items', markers, ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged, ...
                'Tag', 'Marker');
            
            uilabel(g, 'Text', 'Marker Size');
            uispinner(g, 'Value', 15, ...
                'Limits', [0 100], 'LowerLimitInclusive', 'off', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged, ...
                'Tag', 'MarkerSize');
            
            uilabel(g, 'Text', 'Line Width');
            uispinner(g, 'Value', 1, ...
                'Limits', [0 10], 'LowerLimitInclusive', 'off', ...
                'ValueChangedFcn', @obj.onPlotSettingsChanged, ...
                'Tag', 'LineWidth');
        end
        function setupSteadyStateSettings(obj)
            p = uipanel(obj.SidePanelGrid, ...
                'Title', 'Steady-State Settings', ...
                'BorderType', 'none');
            g = uigridlayout(p, ...
                'RowHeight', repmat({'fit'}, 1, 6), ...
                'ColumnWidth', {'fit', 'fit', 'fit'}, ...
                'ColumnSpacing', 10, ...
                'Padding', 10*ones(1,4), ...
                'Scrollable', false);
            
            uilabel(g, 'Text', 'INCLANGL');
            uispinner(g, 'Value', 0, 'Step', 1, 'Limits', [-90 90], ...
                'ValueChangedFcn', @obj.onSteadyStateSettingsChanged, ...
                'Tag', 'INCLANGL');
            uilabel(g, 'Text', '[deg]', ...
                'HorizontalAlignment', 'center');
            
            uilabel(g, 'Text', 'INFLPRES');
            uispinner(g, 'Value', 0.8, 'Step', 0.1, ...
                'ValueChangedFcn', @obj.onSteadyStateSettingsChanged, ...
                'Limits', [0 100], 'LowerLimitInclusive', 'off', ...
                'Tag', 'INFLPRES');
            uilabel(g, 'Text', '[bar]', ...
                'HorizontalAlignment', 'center');
            
            uilabel(g, 'Text', 'FZW');
            uispinner(g, 'Value', 1000, 'Step', 100, ...
                'ValueChangedFcn', @obj.onSteadyStateSettingsChanged, ...
                'Limits', [0 100E3], 'LowerLimitInclusive', 'off', ...
                'Tag', 'FZW');
            uilabel(g, 'Text', '[N]', ...
                'HorizontalAlignment', 'center');
            
            uilabel(g, 'Text', 'TYRESIDE');
            uidropdown(g, 'Items', {'LEFT', 'RIGHT'}, ...
                'ItemsData', {0, 1}, ...
                'ValueChangedFcn', @obj.onSteadyStateSettingsChanged, ...
                'Tag', 'TYRESIDE');
        end
        function setupAxes(obj)
            ax = ui.FrictionEllipseAxes(obj.MainGrid, ...
                'Model', obj.Model);
            obj.Axes = ax;
        end
        function setupListeners(obj)
            addlistener(obj, 'TyreModelChanged', @obj.onModelChanged);
        end
    end
    methods (Access = protected)
        function setup(obj)
            set(obj, 'Position', [0 0 800 400])
            setupMainGrid(obj)
            setupAxes(obj)
            setupSidePanel(obj)
            setupPlotSettings(obj)
            setupSteadyStateSettings(obj)
            setupListeners(obj)
        end
        function update(obj)
            updateSidebarState(obj)
        end
    end
end
