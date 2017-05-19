
classdef EMLCoverage < handle
    properties
        geographicCoverage;
        temporalCoverage;
        taxonomicCoverage;
    end
    
    methods
        
        function emlCoverage = EMLCoverage(geo_coverage, temp_coverage, tax_coverage) 
            % EMLCoverage Creates a new, minimally valid instance of the EMLCoverage class
            
            this.geographicCoverage = geo_coverage;  
            this.temporalCoverage = temp_coverage;
            this.taxonomicCoverage = tax_coverage;
        end
    end
end