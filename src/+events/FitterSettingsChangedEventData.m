classdef (ConstructOnLoad) FitterSettingsChangedEventData < event.EventData
   properties
      Settings struct
   end
   methods
      function eventData = FitterSettingsChangedEventData(settings)
         eventData.Settings = settings;
      end
   end
end