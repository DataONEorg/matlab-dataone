classdef TemporalCoverage
    properties
        singleDateTime;
        rangeOfDates;
        references;
        id;
    end
    methods
        function this = TemporalCoverage(begin_date, end_date)
            this.rangeOfDates = struct('begin_date', begin_date, 'end_date', end_date);
        end
    end
end