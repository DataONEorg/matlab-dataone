classdef GeographicCoverage < handle
    properties
        geographicDescription;
        boundingCoordinates;
        datasetGPolygon;
        boundingAltitudes;
        references;
        id;
        system;
        scope;        
    end
    
    methods
        function this = GeographicCoverage()            
        end
        
        function this = setBoundingCoordinates(this, west, east, north, south) 
            this.boundingCoordinates = struct('westBoundingCoordinate', west, 'eastBoundingCoordinate', east, 'northBoundingCoordinate', north, 'southBoundingCoordinate', south);

        end
        
        function this = setGeographicDescription(this, geo_desc)
            this.geographicDescription = geo_desc;
        end
        
        function this = setDataSetGPolygon()
            
        end
        
        function this = setBoundingAltitudes(this, altitudeMinimum, altitudeMaximum, altitudeUnits)
            this.boundingAltitudes = struct('altitudeMinimum', altitudeMinimum, 'altitudeMaximum', altitudeMaximum, 'altitudeUnits', altitudeUnits);
        end
    end
end
    
