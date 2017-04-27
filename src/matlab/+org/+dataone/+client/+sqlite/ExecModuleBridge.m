classdef ExecModuleBridge < hgsetget
    % EXECDEPENDENCYBRIDGE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        % An execution seq that is a foreign key to the execmeta table
        exec_seq;
        % A module id that is a foreign key to the modulemeta table
        module_id;
        % The dependency metadata table name
        moduleTableName = 'execmodulebridge';
    end
    
    methods (Static)
        function create_bridge_table_statement = createExecModuleBridgeTable(tableName)
            % CREATEEXECMODULEBRIDGETABLE Creates a exec_module_bridge metadata table           
            
            create_table_statement = ['create table if not exists ' tableName '('];
            
            create_bridge_table_statement = [create_table_statement ...
                'exec_seq INTEGER not null references execmeta on delete cascade,' ...
                'module_id INTEGER not null references modulemeta on delete cascade,' ...
                'primary key (exec_seq, module_id)' ...
                ');'];
        end      
    end
end
