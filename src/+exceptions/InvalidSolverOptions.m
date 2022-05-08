classdef InvalidSolverOptions < MException 
    methods
        function obj = InvalidSolverOptions()
            errId = 'MFTyreTool:InvalidSolverOptions';
            msgtext = 'Invalid solver options entered by user.';
            obj@MException(errId, msgtext)
        end
    end
end

