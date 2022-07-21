classdef (ConstructOnLoad) SearchResultsAvailable < event.EventData
   properties
      SearchIndices (:,2)
      SearchIndicesIterator (1,1)
   end
   methods
       function e = SearchResultsAvailable(indices, iterator)
           e.SearchIndices = indices;
           e.SearchIndicesIterator = iterator;
      end
   end
end