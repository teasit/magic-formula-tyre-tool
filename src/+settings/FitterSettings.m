classdef FitterSettings < settings.AbstractSettings
    %FITTERSETTINGS Contains app settings for fitter
    properties (SetObservable, AbortSet)
        FitModes magicformula.v62.FitMode = magicformula.v62.FitMode.empty
        OptimizerSettings optim.options.Fmincon = optimoptions('fmincon');
    end
    methods
        function set.OptimizerSettings(obj, x)
            switch class(x)
                case 'optim.options.Fmincon'
                    obj.OptimizerSettings = x;
                case 'struct'
                    obj.OptimizerSettings.Algorithm = x.Algorithm;
                    obj.OptimizerSettings.MaxIterations = x.MaxIter;
                    obj.OptimizerSettings.UseParallel = x.UseParallel;
                    obj.OptimizerSettings.MaxFunctionEvaluations = x.MaxFunEvals;
            end
        end
        function obj = FitterSettings()
        end
    end
end