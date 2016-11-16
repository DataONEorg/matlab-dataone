classdef QueryEngineModel
    %QUERYENGINEMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        commentStart = '% ';
        quote = char(39);
        showComments = true;
    end
    
    methods
        
        function qem = QueryEngineModel() 
            
        end
        
        function qem = setCommentStart(qem, commentStart)
            qem.commentStart = commentStart;
        end
        
        function qem = setShowComments(qem,showComments)
            qem.showComments = showComments;
        end
        
        function qem = setQuote(qem, quote) 
            qem.quote = quote;
        end
    end
    
end


