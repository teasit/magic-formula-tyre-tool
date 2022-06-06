classdef TyreAnalysisPanelViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        %Sidebar for Fitter is shown by default
        ShowSidebar logical = true
    end
end