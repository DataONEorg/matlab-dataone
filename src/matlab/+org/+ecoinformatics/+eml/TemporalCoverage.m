classdef TemporalCoverage < handle
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
            this.rangeOfDates = struct('beginDate', begin_date, 'endDate', end_date);
        end
        
        function this = setSingleDateTime(this, date) 
            this.singleDateTime = date;
        end
    end
end