classdef FitterSettings < settings.AbstractSettings
    %FITTERSETTINGS Contains app settings for fitter
    properties (SetObservable, AbortSet)
        FitModes magicformula.FitMode = magicformula.FitMode.empty
        DownsampleFactor double = 1
        OptimizerSettings struct = struct.empty
    end
    methods
        function set.OptimizerSettings(obj, x)
            switch class(x)
                case 'optim.options.Fmincon'
                    obj.OptimizerSettings = struct(x);
                case 'struct'
                    obj.OptimizerSettings = x;
            end
        end
    end
end