classdef CouldNotExportTYDEX < MException 
    methods
        function obj = CouldNotExportTYDEX()
            errId = 'MFTyreTool:CouldNotExportTYDEX';
            msgtext = 'Could not export measurements to selected folder.';
            obj@MException(errId, msgtext)
        end
    end
end

