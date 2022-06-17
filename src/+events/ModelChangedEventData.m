classdef (ConstructOnLoad) ModelChangedEventData < event.EventData
   properties
      Model magicformula.Model = magicformula.v62.Model.empty
   end
   methods
      function eventData = ModelChangedEventData(model)
         eventData.Model = model;
      end
   end
end