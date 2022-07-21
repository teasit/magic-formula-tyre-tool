classdef (ConstructOnLoad) SearchTextChanged < event.EventData
   properties
      Text char
   end
   methods
       function e = SearchTextChanged(text)
         e.Text = text;
      end
   end
end