classdef TyrePlotFrictionEllipsePanelViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)      
        SLIPANGL_Max double = 15
        SLIPANGL_Step double = 3
        LONGSLIP_Max double = 0.15
        LONGSLIP_Step double = 0.01
        INFLPRES double = 80E3
        INCLANGL double = 0
        FZW double = 1E3
        TYRESIDE double = 0
        
        Limits double = [5000 5000]
        
        AxisEqual logical = true
        AxisManualLimits logical = true
        LegendOn logical = true
        Marker char = 'none'
        MarkerSize double = 10
        LineWidth double = 1
    end
end