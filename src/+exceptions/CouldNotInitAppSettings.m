classdef CouldNotInitAppSettings < MException 
    methods
        function obj = CouldNotInitAppSettings()
            errId = 'MagicFormulaTyreTool:CouldNotInitAppSettings';
            msgtext = 'Could not initialize persistent app settings.';
            obj@MException(errId, msgtext)
        end
    end
end

