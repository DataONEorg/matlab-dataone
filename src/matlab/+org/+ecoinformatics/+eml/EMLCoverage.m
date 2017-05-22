
classdef EMLCoverage < hgsetget
    properties
        %geographicCoverage;
        %temporalCoverage;
        %taxonomicCoverage;
        coverage_struct;
    end
    
    methods
        
        function this = EMLCoverage(geo_coverage, temp_coverage)
            % EMLCoverage Creates a new, minimally valid instance of the EMLCoverage class
            
            this.coverage_struct = struct('geographicCoverage', geo_coverage, ...
                                'temporalCoverage', temp_coverage);
        end
        
        function coverage_map = getNestedMap(this, s)
            
            if isempty(s)
                coverage_map = [];
                return;
            end
            
            fields = fieldnames(s);
            valueSet = cell(1, length(fields));
            keySet = cell(1, length(fields));
            
            for i = 1 : length(fields)
                value = s.(fields{i});
                
                if isempty(value) == 0 && isa(value, 'org.ecoinformatics.eml.GeographicCoverage')
                    keySet{i} = fields{i};
                    valueSet{i} = value.getNestedMap();
                end
                
                if isempty(value) == 0 && isa(value, 'org.ecoinformatics.eml.TemporalCoverage')
                    keySet{i} = fields{i};
                    valueSet{i} = value.getNestedMap(value);
                end
                
%                 if isempty(value) == 0 && isa(value, 'org.ecoinformatics.eml.TaxonomicCoverage')
%                     keySet{i} = fields{i};
%                     valueSet{i} = value.getNestedMap(value);
%                 else
%                     keySet{i} = fields{i};
%                     valueSet{i} = [];
%                 end
            end
            coverage_map = containers.Map(keySet, valueSet);
        end
        
            
        function dom_node = convert2DomNode(this, anMap, dom_node, document)
            if isempty(dom_node)
                document = com.mathworks.xml.XMLUtils.createDocument('rootNode');
                documentNode = document.getDocumentElement();
                dom_node = document.createElement('coverage');
                documentNode.appendChild(dom_node);
            end
            
            keySet = anMap.keys;
            valueSet = anMap.values;
            for i = 1: length(keySet)
                ele_node = document.createElement(keySet{i});
                
                if isa(valueSet{i}, 'containers.Map') == 0
                    if isnumeric(valueSet{i}) == 1
                        ele_node_text_node = document.createTextNode(num2str(valueSet{i}));
                    else
                        ele_node_text_node = document.createTextNode(char(valueSet{i}));
                    end
                    ele_node.appendChild(ele_node_text_node);
                else
                    ele_node = convert2DomNode(this, valueSet{i}, ele_node, document);
                end
                
                dom_node.appendChild(ele_node);
            end
        end
    end
end