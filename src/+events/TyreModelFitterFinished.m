classdef (ConstructOnLoad) TyreModelFitterFinished < event.EventData
   properties
      ParametersFitted magicformula.v61.Parameters
   end
   methods
      function eventData = TyreModelFitterFinished(params)
         eventData.ParametersFitted = params;
      end
   end
end