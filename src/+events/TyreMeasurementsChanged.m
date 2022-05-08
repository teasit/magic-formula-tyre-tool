classdef (ConstructOnLoad) TyreMeasurementsChanged < event.EventData
   properties
      Measurements = tydex.Measurement.empty
      FitModeFlags containers.Map
   end
   methods
      function eventData = TyreMeasurementsChanged(measurements, flags)
          arguments
              measurements tydex.Measurement = tydex.Measurement.empty
              flags containers.Map = containers.Map.empty
          end
         eventData.Measurements = measurements;
         eventData.FitModeFlags = flags;
      end
   end
end