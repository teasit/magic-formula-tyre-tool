classdef CouldNotExportTYDEX < MException 
    methods
        function obj = CouldNotExportTYDEX()
            errId = 'MagicFormulaTyreTool:CouldNotExportTYDEX';
            msgtext = 'Could not export measurements to selected folder.';
            obj@MException(errId, msgtext)
        end
    end
end

