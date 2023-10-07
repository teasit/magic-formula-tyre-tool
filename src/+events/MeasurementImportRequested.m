classdef (ConstructOnLoad) MeasurementImportRequested < event.EventData
    properties
        Files cell
        Parser function_handle;
    end
    methods
        function eventData = MeasurementImportRequested(files, parser)
            eventData.Files = cellstr(files);
            eventData.Parser = parser;
        end
    end
end