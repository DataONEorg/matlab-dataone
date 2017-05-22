classdef TemporalCoverage < hgsetget
    properties
        singleDateTime;
        rangeOfDates;
        references;
        id;
    end
    methods
        function this = TemporalCoverage()
            
        end
        
        function this = setRangeOfDates(this, begin_date, end_date) 
            if isempty(begin_date) == 0
                beginDate = struct('calendarDate', char(begin_date));
            end
            
            if isempty(end_date) == 0
                endDate = struct('calendarDate', char(end_date));
            end
            
            this.rangeOfDates = struct('beginDate', beginDate, 'endDate', endDate);
        end
        
        function this = setSingleDateTime(this, date_value)
            if isempty(date_value) == 0
                singleDate = struct('calendarDate', char(date_value));
            end
            this.singleDateTime = struct('singleDateTime', singleDate);
        end
        
        function temporal_coverage_map = getNestedMap(this, object)
            
            if isempty(object)
                temporal_coverage_map = [];
                return;
            end
            
            propertyNames = properties(object);
            valueSet = cell(1, length(propertyNames));
            keySet = cell(1, length(propertyNames));
            
            for i = 1 : length(propertyNames)
                value = object.get(propertyNames{i});
                if isa(value, 'struct') == 0
                    keySet{i} = propertyNames{i};
                    valueSet{i} = value;
                else 
                    child_map = getNestedMapHelper(this, value);
                    keySet{i} = propertyNames{i};
                    valueSet{i} = child_map;
                end
            end
            temporal_coverage_map = containers.Map(keySet, valueSet);
        end
           
        function aMap = getNestedMapHelper(this, s)
            if isempty(s)
                aMap = [];
                return;
            end

            fields = fieldnames(s);
            valueSet = cell(1, length(fields));
            keySet = cell(1, length(fields));
            
            for i = 1 : length(fields)
                value = s.(fields{i});
                if isa(value, 'struct') == 0
                    keySet{i} = fields{i};
                    valueSet{i} = value;
                else 
                    child_map = getNestedMapHelper(this, value);
                    keySet{i} = fields{i};
                    valueSet{i} = child_map;
                end
            end
            aMap = containers.Map(keySet, valueSet);
        end
        
        function dom_node = convert2DomNode(this, anMap, dom_node, document)
            if isempty(dom_node)
                document = com.mathworks.xml.XMLUtils.createDocument('rootNode');
                documentNode = document.getDocumentElement();
                dom_node = document.createElement('temporalCoverage');
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