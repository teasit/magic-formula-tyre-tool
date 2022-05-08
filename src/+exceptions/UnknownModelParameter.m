classdef UnknownModelParameter < MException
    properties
        ParameterName char
    end
    methods
        function obj = UnknownModelParameter(name)
            arguments
                name char
            end
            errId = 'MFTyreTool:UnknownModelParameter';
            msgtext = sprintf('Unknown parameter name "%s".', name);
            obj@MException(errId, msgtext)
            obj.ParameterName = name;
        end
    end
end

