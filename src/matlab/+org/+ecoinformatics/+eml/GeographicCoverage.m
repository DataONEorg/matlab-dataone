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
        
        function geo_coverage_map = getNestedMap(this)
            geo_coverage_map = containers.Map();
            if isempty(this) 
                return;
            end
            
            fields = fieldnames(this);
            valueSet = cell(1, length(fields));
            keySet = cell(1, length(fields));
            
            for i = 1 : length(fields)
               value = this.(fields{i});
               if isa(value, 'struct') == 0 
                   keySet{i} = fields{i};
                   valueSet{i} = value;
               else
                   anStruct = struct(value);
                   anMap = containers.Map(fieldnames(anStruct), struct2cell(anStruct));
                   keySet{i} = fields{i};
                   valueSet{i} = anMap;
               end
            end
            geo_coverage_map = containers.Map(keySet, valueSet);
        end
    end
end
    
