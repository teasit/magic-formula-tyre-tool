classdef CouldNotLoadAppSettings < MException 
    methods
        function obj = CouldNotLoadAppSettings()
            errId = 'MagicFormulaTyreTool:CouldNotLoadAppSettings';
            msgtext = 'Could not load persistent app settings.';
            obj@MException(errId, msgtext)
        end
    end
end

