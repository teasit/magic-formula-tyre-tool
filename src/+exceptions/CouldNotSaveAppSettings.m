classdef CouldNotSaveAppSettings < MException 
    methods
        function obj = CouldNotSaveAppSettings()
            errId = 'MFTyreTool:CouldNotSaveAppSettings';
            msgtext = 'Could not save persistent app settings.';
            obj@MException(errId, msgtext)
        end
    end
end

