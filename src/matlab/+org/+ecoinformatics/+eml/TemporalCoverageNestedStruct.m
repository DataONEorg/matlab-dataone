classdef TemporalCoverageNestedStruct < hgsetget
    properties
        singleDateTime;
        rangeOfDates;
        references;
        id;
    end
    methods
        function this = TemporalCoverageNestedStruct()
            this.singleDateTime = struct(struct('calendarDate', {}));
%             this.rangeOfDates = struct('beginDate', struct('calendarDate', {}), 'endDate', struct('calendarDate', {}));
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
            this.singleDateTime(end + 1, 1) = singleDate;
        end
        
        function temporal_coverage_map = getNestedMap(this)          
            if isempty(this)
                temporal_coverage_map = [];
                return;
            end

            orderedFields = {'singleDateTime', 'rangeOfDates'};
            orderedValues = cell(1, length(orderedFields));
            for i = 1 : length(orderedFields)
                orderedValues{i} = this.(orderedFields{i});
            end
            tmp = {orderedFields{:}; orderedValues{:}};
            temporalStruct = struct(tmp{:});
            orderedTemporalStruct = orderfields(temporalStruct, orderedFields);
            
            % remove empty values
            keySet = {};
            valueSet = {};
            
            k = 1;
            for i = 1 : length(orderedFields)
                value = orderedTemporalStruct.(orderedFields{i});
                if isa(value, 'struct') == 0
                    if ~isempty(value)
                        keySet{k} = orderedFields{i};
                        valueSet{k} = value;
                        k = k + 1;
                    end
                else
                    if ~isempty(value)
                        child_map = getNestedMapHelper(this, value);
                        keySet{k} = orderedFields{i};
                        valueSet{k} = child_map;
                        k = k + 1;
                    end
                end
            end
            tmp = {keySet{:}; valueSet{:}};
            temporal_coverage_map = struct(tmp{:});
        end
           
        function resMap = getNestedMapHelper(this, S)
            if isempty(S)
                resMap = [];
                return;
            end
            
            resMap = struct();
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
                
                tmp = {keySet{:}; valueSet{:}};
                if  k == 1
                    resMap = struct(tmp{:});
                else
                    resMap = [resMap ; struct(tmp{:})];
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
            
            keySet = fields(anMap);
            valueSet = cell(1, length(keySet));
            for i = 1 : length(keySet)
                %ele_node = document.createElement(keySet{i});
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