classdef (ConstructOnLoad) MeasurementSelectionChanged < event.EventData
   properties
      Measurements = tydex.Measurement.empty
      Indices logical
   end
   methods
       function e = MeasurementSelectionChanged(measurements, indices)
          arguments
              measurements tydex.Measurement = tydex.Measurement.empty
              indices logical = logical.empty
          end
         e.Measurements = measurements;
         e.Indices = indices;
      end
   end
end