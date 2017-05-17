classdef GeographicCoverage
    properties
        geographicDescription;
        boundingCoordinates;
        datasetGPolygon;
        references;
        id;
        system;
        scope;
    end
    
    methods
        function this = GeographicCoverage()            
        end
        
        function this = setBooundingCoordinates(west, east, north, south) 
            this.boundingCoordinates = struct('west', west, 'east', east, 'north', north, 'south', south);
        end
        
        function this = setGeographicDescription(g_desc)
            this.geographicDescription = geo_desc;
        end
        
        function this = setDataSetGPolygon()
            
        end
    end
end
    
