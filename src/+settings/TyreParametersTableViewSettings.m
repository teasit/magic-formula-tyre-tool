classdef TyreParametersTableViewSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        %Only parameters that will be adjusted by Fitter are shown.
        ShowFittableParameters logical = true
        
        %Opposite of the "ShowFittableParameters"
        ShowNonFittableParameters logical = true
        
        %Only parameters relevant for currently selected FitModes are shown.
        ShowOnlyFitModeParameters logical = false
    end
end