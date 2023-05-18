classdef (ConstructOnLoad) ModelChangedEventData < event.EventData
   properties
      Model MagicFormulaTyre = MagicFormulaTyre.empty
   end
   methods
      function eventData = ModelChangedEventData(model)
         eventData.Model = model;
      end
   end
end