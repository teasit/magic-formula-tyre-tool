classdef TyreAnalysisPanelViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        %Sidebar for Fitter is shown by default
        ShowSidebar logical = true
        TyrePlotCurvesPanel settings.TyrePlotCurvesPanelViewSettings
        TyrePlotFrictionEllipsePanel ...
            settings.TyrePlotFrictionEllipsePanelViewSettings
    end
    
    methods
        function obj = TyreAnalysisPanelViewSettings()
                obj.TyrePlotCurvesPanel = ...
                    settings.TyrePlotCurvesPanelViewSettings();
                obj.TyrePlotFrictionEllipsePanel = ...
                    settings.TyrePlotFrictionEllipsePanelViewSettings();
        end
    end
end