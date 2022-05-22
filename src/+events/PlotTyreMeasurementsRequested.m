classdef (ConstructOnLoad) PlotTyreMeasurementsRequested < event.EventData
   properties
      Measurements = tydex.Measurement.empty
   end
   methods
       function e = PlotTyreMeasurementsRequested(measurements)
          arguments
              measurements tydex.Measurement = tydex.Measurement.empty
          end
         e.Measurements = measurements;
      end
   end
end