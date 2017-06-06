classdef QueryEngineModel
    % QUERYENGINEMODEL This class defines which logic engine is used for
    % logic query.
    
    properties
        commentStart = '% ';
        quote = char(39); % Single quote
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


