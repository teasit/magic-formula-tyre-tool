classdef CouldNotResetAppSettings < MException 
    methods
        function obj = CouldNotResetAppSettings()
            errId = 'MFTyreTool:CouldNotResetAppSettings';
            msgtext = 'Could not reset persistent app settings.';
            obj@MException(errId, msgtext)
        end
    end
end

