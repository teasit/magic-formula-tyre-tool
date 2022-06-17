classdef CouldNotExportTIR < MException 
    methods
        function obj = CouldNotExportTIR(file)
            arguments
                file char
            end
            errId = 'MagicFormulaTyreTool:CouldNotExportTIR';
            msgtext = sprintf('Could not export model to "%s".', file);
            obj@MException(errId, msgtext)
        end
    end
end

