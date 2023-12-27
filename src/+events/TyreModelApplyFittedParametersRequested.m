classdef (ConstructOnLoad) TyreModelApplyFittedParametersRequested < event.EventData
   properties
      ParameterNames cell
   end
   methods
       function event = TyreModelApplyFittedParametersRequested(names)
         event.ParameterNames = names;
      end
   end
end