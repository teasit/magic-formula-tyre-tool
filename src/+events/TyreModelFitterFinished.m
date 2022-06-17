classdef (ConstructOnLoad) TyreModelFitterFinished < event.EventData
   properties
      ParametersFitted magicformula.v62.Parameters
   end
   methods
      function eventData = TyreModelFitterFinished(params)
         eventData.ParametersFitted = params;
      end
   end
end