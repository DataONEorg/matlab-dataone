
classdef EMLCoverage < hgsetget
    properties
        map;
    end
    
    methods
        
        function this = EMLCoverage(geo_coverage, temp_coverage, taxonomy_coverage)
            % EMLCoverage Creates a new, minimally valid instance of the EMLCoverage class
  
            if isempty(geo_coverage) == 0 && isa(geo_coverage, 'org.ecoinformatics.eml.GeographicCoverageNestedStruct')   
               this.map = containers.Map('geographicCoverage', geo_coverage); 
            end
            
            if isempty(temp_coverage) == 0 && isa(temp_coverage, 'org.ecoinformatics.eml.TemporalCoverageNestedStruct')
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

            tmp = {keySet{:}; valueSet{:}};
            coverage_map = struct(tmp{:});
        end
        
            
        function dom_node = convert2DomNode(this, anMap, dom_node, document)
            if isempty(dom_node)
                if isempty(document)
                    document = com.mathworks.xml.XMLUtils.createDocument('rootNode');
                end
                documentNode = document.getDocumentElement();
                dom_node = document.createElement('coverage');
                documentNode.appendChild(dom_node);
            end
            
            keySet = fields(anMap);
            valueSet = cell(length(keySet));
            for i = 1 : length(keySet)
%                 ele_node = document.createElement(keySet{i});
                valueSet{i} = anMap.(keySet{i});
                
                if isa(valueSet{i}, 'struct') == 0
                    ele_node = document.createElement(keySet{i});
                    if isnumeric(valueSet{i}) == 1
                        ele_node_text_node = document.createTextNode(num2str(valueSet{i}));
                    else
                        ele_node_text_node = document.createTextNode(char(valueSet{i}));
                    end
                    ele_node.appendChild(ele_node_text_node);
                    dom_node.appendChild(ele_node);
                else
                    for j = 1 : length(valueSet{i}) % loop over struct array
                        ele_node = document.createElement(keySet{i});
                        ele_node = convert2DomNode(this, valueSet{i}(j), ele_node, document);
                        dom_node.appendChild(ele_node);
                    end
                end
                
%                 dom_node.appendChild(ele_node);
            end
        end
        
        function xml = toXML(this)
            mapObj = this.getNestedMap();
            dom_node = this.convert2DomNode(mapObj, [], []);
            xml = xmlwrite(dom_node);
        end
    end
end