
classdef EMLCoverage < hgsetget
    properties
        map;
    end
    
    methods
        
        function this = EMLCoverage(geo_coverage, temp_coverage, taxonomy_coverage)
            % EMLCoverage Creates a new, minimally valid instance of the EMLCoverage class
            
            if isempty(geo_coverage) == 0 && isa(geo_coverage, 'org.ecoinformatics.eml.GeographicCoverage')
               this.map = containers.Map('geographicCoverage', geo_coverage); 
            end
            
            if isempty(temp_coverage) == 0 && isa(temp_coverage, 'org.ecoinformatics.eml.TemporalCoverage')
               new_map = containers.Map('temporalCoverage', temp_coverage); 
               this.map = [this.map ; new_map];
            end
            
            if isempty(taxonomy_coverage) == 0 && isa(taxonomy_coverage, 'org.ecoinformatics.eml.TaxonomicCoverage')
               new_map = containers.Map('taxonomicCoverage', taxonomy_coverage); 
               this.map = [this.map ; new_map];
            end
        end
        
        function coverage_map = getNestedMap(this)
            
            if isempty(this.map)
                coverage_map = [];
                return;
            end
            
            map_keys = this.map.keys;
            valueSet = cell(1, length(map_keys));
            keySet = cell(1, length(map_keys));
            
            for i = 1 : length(map_keys)
                value = this.map(map_keys{i});
                
                if isempty(value) == 0 
                    keySet{i} = map_keys{i};
                    valueSet{i} = value.getNestedMap();
                end
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
            for i = 1 : length(keySet)
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
        
        function xml = toXML(this)
            mapObj = this.getNestedMap();
            dom_node = this.convert2DomNode(mapObj, [], []);
            xml = xmlwrite(dom_node);
        end
    end
end