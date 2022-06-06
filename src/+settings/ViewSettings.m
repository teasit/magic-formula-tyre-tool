classdef ViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        TyreModelPanel settings.TyreModelPanelViewSettings
        TyreAnalysisPanel settings.TyreAnalysisPanelViewSettings
        TyreParametersTable settings.TyreParametersTableViewSettings
        Layout settings.ViewLayoutSettings
    end
    methods
        function obj = ViewSettings()
            obj.TyreModelPanel = settings.TyreModelPanelViewSettings();
            obj.TyreAnalysisPanel = settings.TyreAnalysisPanelViewSettings();
            obj.TyreParametersTable = settings.TyreParametersTableViewSettings();
            obj.Layout = settings.ViewLayoutSettings();
        end
    end
end