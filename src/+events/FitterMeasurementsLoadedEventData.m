classdef (ConstructOnLoad) FitterMeasurementsLoadedEventData < event.EventData
   properties
      FitModeFlags containers.Map
   end
   methods
      function eventData = FitterMeasurementsLoadedEventData(flagsMap)
         eventData.FitModeFlags = flagsMap;
      end
   end
end