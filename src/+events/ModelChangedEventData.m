classdef (ConstructOnLoad) ModelChangedEventData < event.EventData
   properties
      Model mftyre.Model = mftyre.v62.Model.empty
   end
   methods
      function eventData = ModelChangedEventData(model)
         eventData.Model = model;
      end
   end
end