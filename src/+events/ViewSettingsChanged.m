classdef (ConstructOnLoad) ViewSettingsChanged < event.EventData
   properties
      Settings (1,1) ui.ViewSettings
   end
   methods
      function eventData = ViewSettingsChanged(settings)
         eventData.Settings = settings;
      end
   end
end