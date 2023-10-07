classdef (Hidden) ExampleParser < tydex.Parser
    methods (Access = protected)
        [measurements, bins, binvalues] = parse(obj,file)
    end
    methods
        function [measurements, bins, binvalues] = run(obj, file)
            [measurements, bins, binvalues] = parse(obj, file);
            measurements = measurements.index();
        end
    end
end