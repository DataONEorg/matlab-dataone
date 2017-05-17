classdef TemporalCoverage
    properties
        singleDateTime;
        rangeOfDates;
        references;
        id;
    end
    methods
        function this = TemporalCoverage()
            
        end
        
        function this = setRangeOfDates(begin_date, end_date) 
            this.rangeOfDates = struct('begin_date', begin_date, 'end_date', end_date);
        end
    end
end