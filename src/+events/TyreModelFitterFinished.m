classdef (ConstructOnLoad) TyreModelFitterFinished < event.EventData
   properties
      ParametersFitted mftyre.v62.Parameters
   end
   methods
      function eventData = TyreModelFitterFinished(params)
         eventData.ParametersFitted = params;
      end
   end
end