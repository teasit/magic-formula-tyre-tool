classdef (ConstructOnLoad) FittingModesChangedEventData < event.EventData
   properties
      FitModes magicformula.v62.FitMode
   end
   methods
      function eventData = FittingModesChangedEventData(fitmodes)
         eventData.FitModes = fitmodes;
      end
   end
end