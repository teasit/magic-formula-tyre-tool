classdef (ConstructOnLoad) RangeChanged < event.EventData
   properties
      Range (1,2) double
   end
   methods
      function eventData = RangeChanged(range)
         eventData.Range = range;
      end
   end
end