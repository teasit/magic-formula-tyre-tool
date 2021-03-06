classdef CouldNotImportTIR < MException 
    methods
        function obj = CouldNotImportTIR(file)
            arguments
                file char
            end
            errId = 'MagicFormulaTyreTool:CouldNotImportTIR';
            msgtext = sprintf('Could not import TIR file "%s".', file);
            obj@MException(errId, msgtext)
        end
    end
end

