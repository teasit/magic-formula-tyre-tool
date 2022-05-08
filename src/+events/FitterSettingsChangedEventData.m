classdef (ConstructOnLoad) FitterSettingsChangedEventData < event.EventData
   properties
      Settings optim.options.Fmincon
   end
   methods
      function eventData = FitterSettingsChangedEventData(settings)
         eventData.Settings = settings;
      end
   end
end