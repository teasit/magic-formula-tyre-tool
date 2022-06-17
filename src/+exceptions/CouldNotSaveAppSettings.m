classdef CouldNotSaveAppSettings < MException 
    methods
        function obj = CouldNotSaveAppSettings()
            errId = 'MagicFormulaTyreTool:CouldNotSaveAppSettings';
            msgtext = 'Could not save persistent app settings.';
            obj@MException(errId, msgtext)
        end
    end
end

