classdef TyrePlotCurvesPanelViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        AutoRefresh logical = false
        LegendOn logical = true
        HoldOn logical = false
        DataShow logical = false
        ModelShow logical = true
        XAxis char = 'LONGSLIP'
        YAxis char = 'FX'
        XRange (1,2) = [-1 1]
        
        SteadyStateValues cell = {{0} {0} {0} {0.8E5} {1.5E3}}
        SteadyStateValuesSelected cell = [{0} {0} {0} {0.8E5} {1.5E3}]
        SteadyStateNamesSelected cell = {
            'LONGSLIP'
            'SLIPANGL'
            'INCLANGL'
            'INFLPRES'
            'FZW'}'
        XAxisRangeLONGSLIP (1,2) = [-1 1]
        XAxisRangeSLIPANGL (1,2) = [-15 15]
        XAxisRangeINCLANGL (1,2) = [-6 6]
        XAxisRangeINFLPRES (1,2) = [0.8 1.0]
        XAxisRangeFZW      (1,2) = [500 1500]
    end
end