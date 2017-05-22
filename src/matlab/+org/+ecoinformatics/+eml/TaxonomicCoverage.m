classdef TaxonomicCoverage < handle
    properties
        taxonomicSystem;
        generalTaxonomicCoverage;
        taxonomicClassification;
        references;
        id;
    end
    
    methods
        function this = TaxonomicCoverage()
            
        end
        
        function taxonomy_coverage_map = getNestedMap(this, object)           
            if isempty(object)
                taxonomy_coverage_map = [];
                return;
            end
        end
    end
end