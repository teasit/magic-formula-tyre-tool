classdef ViewLayoutSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        %Move Analysis Tab To Right
        MoveAnalysisPanelToSecondaryTabGroup logical = false
    end
end