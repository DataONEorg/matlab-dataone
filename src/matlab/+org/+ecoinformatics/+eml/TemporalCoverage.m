classdef TemporalCoverage < hgsetget
    properties
        singleDateTime;
        rangeOfDates;
        references;
        id;
    end
    methods
        function this = TemporalCoverage()
            this.singleDateTime = struct();
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
            if size(this.singleDateTime, 2) > 0 
                this.singleDateTime = [ this.singleDateTime ; singleDate ]; % struct array
            else
                this.singleDateTime = singleDate;
            end
        end
        
        function temporal_coverage_map = getNestedMap(this)          
            if isempty(this)
                temporal_coverage_map = [];
                return;
            end
            
            propertyNames = properties(this);
            valueSet = cell(1, length(propertyNames));
            keySet = cell(1, length(propertyNames));
            
            for i = 1 : length(propertyNames)
                value = this.get(propertyNames{i});
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
           
        function resMap = getNestedMapHelper(this, S)
            if isempty(S)
                resMap = [];
                return;
            end

            for k = 1 : size(S, 1)
                fields = fieldnames(S(k));
                valueSet = cell(1, length(fields));
                keySet = cell(1, length(fields));
                
                for i = 1 : length(fields)
                    value = S(k).(fields{i});
                    if isa(value, 'struct') == 0
                        keySet{i} = fields{i};
                        valueSet{i} = value;
                    else                        
                        child_map = getNestedMapHelper(this, value);
                        keySet{i} = fields{i};
                        valueSet{i} = child_map;
                    end
                end
                if k == 1
                    resMap = containers.Map(keySet, valueSet);
                else
                    newMap = containers.Map(keySet, valueSet);
                    resMap = [resMap ; newMap];
                end
            end
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