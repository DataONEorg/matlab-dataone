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
        function this = GeographicCoverage(geo_desc, west, east, north, south)
            this.geographicDescription = geo_desc;
            this.boundingCoordinates = struct('west', west, 'east', east, 'north', north, 'south', south);
 
        end
    end
end
    