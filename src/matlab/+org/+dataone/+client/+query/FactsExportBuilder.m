classdef FactsExportBuilder < hgsetget
    % FACTSEXPORTBUILDER This class defines how to export relational data
    % to prolog facts which can be used by prolog query.
    properties (Constant)
        EOL =java.lang.System.getProperty('line.separator');
        default_query_engine = 'XSB';
    end
    
    properties       
        name;
        fieldCount;
        buffer;
        queryEngineModel;
    end
    

    methods       
        function factsBuilder = FactsExportBuilder(queryEngine, name, varargin)
            
            import org.dataone.client.query.QueryEngineModel;
            
            if isempty(queryEngine)
                queryEngine = 'XSB';
            end
            
            if strcmpi(queryEngine, 'XSB')
                qem = QueryEngineModel();
                qem = qem.setShowComments(true);
                qem = qem.setCommentStart('%');
                qem = qem.setQuote(char(39));
            end
            
            factsBuilder.buffer = java.lang.StringBuilder();
            
            factsBuilder.name = name;
            factsBuilder.queryEngineModel = qem;
            if ~isempty(varargin)
                factsBuilder.fieldCount = length(varargin);
                factsBuilder.addHeader(varargin{:});
            end
        end

        
        function factsBuilder = addHeader(factsBuilder, varargin)
            signature = java.lang.StringBuilder();
            
            signature.append(  'FACT: '    )...
                     .append(  factsBuilder.name        )...
                     .append(  '('         )...
                     .append(  varargin{1}  );
                    
            for i = 2:factsBuilder.fieldCount
                signature.append(  ', '        ).append(  varargin{i}  );
            end
                
            signature.append(  ').'    );               
            factsBuilder.comment(signature.toString());
        end
            
        
        function factsBuilder = addRow(factsBuilder, varargin)
                
            buf = factsBuilder.buffer;
            buf.append(    factsBuilder.name                )...
               .append(    '('                 )...
               .append(    factsBuilder.quote(varargin{1})    );
            
            for i = 2: factsBuilder.fieldCount
                buf.append(    ', '                )...
                   .append(    factsBuilder.quote(varargin{i})    );
            end
                
            buf.append(    ').'    )...
               .append(    factsBuilder.EOL     );     
        end
        
        
        function factsBuilder = comment(factsBuilder, comm)
            if (factsBuilder.queryEngineModel.showComments) 
                buf = factsBuilder.buffer;
                buf.append(     factsBuilder.EOL                             )...
                   .append(     factsBuilder.queryEngineModel.commentStart   )...
                   .append(     comm                               )...
                   .append(     factsBuilder.EOL                             );
            end
        end
            
        
        function value_char = quote(factsBuilder, value)
            
            if isnumeric(value)
                value_char = num2str(value);
                return;
            end
            
            if ischar(value)
                k = strfind(value,'/'); % For character '/' which cannot be displayed correctly with Graphviz
                % Remove the extro double quotes for filePath, archivePaath, and type. The quotes add when we create the dot file
                value_char = [factsBuilder.queryEngineModel.quote, char(value), factsBuilder.queryEngineModel.quote];
            end
                    
        end
        
        
        function qem = getQueryEngineModel(factsBuilder)
            qem = factsBuilder.queryEngineModel;
        end
        
        
        function buffer_char = getBuffer(factsBuilder)
            buffer_char = char(factsBuilder.buffer.toString());
        end
        
        function writeFacts(factsBuilder, factsPath, factsFileName)
            buffer_char = factsBuilder.getBuffer();
            full_facts_path = fullfile(factsPath, factsFileName);
            
            
            [fileId, message] = fopen(full_facts_path,'w+');
            
            if ( fileId == -1 )
                error(['Could not open the facts file ' ...
                    full_facts_path ...
                    ' for writing. The error message was: ' ...
                    message]);
            end
            
            fprintf(fileId, '%s', buffer_char);
            fclose(fileId);
            
        end
    end
    
end

