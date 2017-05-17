
classdef EMLCoverage 
    properties
        geographicCoverage;
        temporalCoverage;
        taxonomicCoverage;
    end
    
    methods
        
        function emlCoverage = EMLCoverage(geo_coverage_ele, temp_coverage_ele, tax_coverage_ele) 
            % EMLCoverage Creates a new, minimally valid instance of the EMLCoverage class
            
            this.geographicCoverage = geo_coverage_ele;  
            this.temporalCoverage = temp_coverage_ele;
            this.taxonomicCoverage = tax_coverage_ele;
        end
    end
end