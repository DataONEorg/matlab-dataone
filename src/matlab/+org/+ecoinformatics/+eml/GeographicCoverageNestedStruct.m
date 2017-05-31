classdef GeographicCoverageNestedStruct < hgsetget
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
        function this = GeographicCoverageNestedStruct()
            this.boundingCoordinates = struct('westBoundingCoordinate', {}, ...
                'eastBoundingCoordinate', {}, ...
                'northBoundingCoordinate', {}, ...
                'southBoundingCoordinate', {});
            
            this.boundingAltitudes = struct('altitudeMinimum', {}, ...
                'altitudeMaximum', {}, ...
                'altitudeUnits', {});
        end
        
        function this = setBoundingCoordinates(this, west, east, north, south) 
            this.boundingCoordinates = struct('westBoundingCoordinate', west, ...
                                              'eastBoundingCoordinate', east, ... 
                                              'northBoundingCoordinate', north, ...
                                              'southBoundingCoordinate', south);

        end
        
        function this = setGeographicDescription(this, geo_desc)
            this.geographicDescription = geo_desc;
        end
        
        function this = setBoundingAltitudes(this, alt_min, alt_max, alt_units)
            this.boundingAltitudes = struct('altitudeMinimum', alt_min, ...
                                            'altitudeMaximum', alt_max, ...
                                            'altitudeUnits', alt_units);
        end
        
        function geo_coverage_map = getNestedMap(this)
            if isempty(this) 
                return;
            end
            
            orderedFields = {'geographicDescription', 'boundingCoordinates', 'datasetGPolygon'};
            orderedValues = {};
            for i = 1 : length(orderedFields)
                orderedValues{end + 1} = this.(orderedFields{i});
            end
            tmp = {orderedFields{:}; orderedValues{:}};
            geoStruct = struct(tmp{:});
            orderedGeoStruct = orderfields(geoStruct, orderedFields);
            
            % remove empty values
            keySet = {};
            valueSet = {};

            k = 1;
            for i = 1 : length(orderedFields)
                value = orderedGeoStruct.(orderedFields{i});
                if isa(value, 'struct') == 0
                    if ~isempty(value)
                        keySet{k} = orderedFields{i};
                        valueSet{k} = value;
                        k = k + 1;
                    end
                else
                    if (~isempty(value))
                        anStruct = struct(value);
                        keySet{k} = orderedFields{i};
                        if strcmp(orderedFields{i}, 'boundingCoordinates')
                            orderedCordinates = orderfields(anStruct, {'westBoundingCoordinate', 'eastBoundingCoordinate', 'northBoundingCoordinate', 'southBoundingCoordinate'});
                            valueSet{k} = orderedCordinates;
                        else
                            valueSet{k} = anStruct;
                        end
                        k = k + 1;
                    end
                end
            end
            tmp = {keySet{:}; valueSet{:}};
            geo_coverage_map = struct(tmp{:});
        end
        
        function dom_node = convert2DomNode(this, anMap, dom_node, document)
            if isempty(dom_node)
                document = com.mathworks.xml.XMLUtils.createDocument('rootNode');                
                documentNode = document.getDocumentElement();
                dom_node = document.createElement('geographicCoverage');
                documentNode.appendChild(dom_node);
            end

            keySet = fields(anMap);
            valueSet = cell(length(keySet));
            for i = 1 : length(keySet) 
                ele_node = document.createElement(keySet{i});  
                valueSet{i} = anMap.(keySet{i});
                if isa(valueSet{i}, 'struct') == 0 
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
    
