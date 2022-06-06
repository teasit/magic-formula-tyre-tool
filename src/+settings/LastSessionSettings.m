classdef LastSessionSettings < settings.AbstractSettings
    properties (SetObservable, AbortSet)
        TyreModelFile char
    end
    methods
        function obj = LastSessionSettings()
        end
    end
end