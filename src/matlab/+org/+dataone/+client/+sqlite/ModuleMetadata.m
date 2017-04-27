classdef ModuleMetadata < hgsetget
    % MODULEMETADATA This class represents all mudules used by a matlab
    % project. There is a foreign key back to ExecMetadata table.
    %  
    properties
        % A simple integer value associated with a module dependency
        module_id;
        % The modules information
        dependencyInfo;
        % The dependency metadata table name
        moduleTableName = 'modulemeta';
    end
    
    methods (Static)        
        function create_dependency_table_statement = createModuleMetaTable(tableName)
            % CREATEDEPENDENCYMETATATABLE Creates a dependency metadata table

            create_table_statement = ['create table if not exists ' tableName '('];
            create_dependency_table_statement = [create_table_statement ...
                'module_id INTEGER primary key,' ...
                'dependencyInfo TEXT,' ...
                'unique(dependencyInfo)' ...
                ');'];
        end
        
        function readDependencyQuery = readModuleMeta(varargin)
            % READMODULEMETA Retrieves saved module dependency metadata
            
            if isempty(varargin)
                % If the input argument doesn't exist yet, then there is
                % no dependency metadata for read, so just return a blank string
                readDependencyQuery = [];
                return;
            end
            
            % Construct a SELECT statement to retrieve the module dependency that match
            % the specified search criteria
            select_statement = ['SELECT * FROM modulemeta'];
            where_clause = '';
            
            % Retrieve dependency information that matches search criteria
            select_statement = [select_statement, where_clause, ';'];
            readDependencyQuery = select_statement;
        end
    end
    
    methods
        function this =  ModuleMetadata(module_dependency_info)
            this.dependencyInfo = module_dependency_info;
        end
        
        function insertModuleQuery = writeModuleMeta(moduleMetadata)
            % WRITEMODULEMETA Saves a single module dependency metadata
                      
            % Construct a SQL INSERT statement for fast insert to the
            % modulemeta table
            modulemeta_colnames = {'dependencyInfo'};
            data_row = moduleMetadata.get(modulemeta_colnames{1});
            
            insertModuleMetaQuery = sprintf('insert into %s (%s) values ', moduleMetadata.moduleTableName, modulemeta_colnames{:});
            insertModuleMetaQueryData = sprintf('("%s");', data_row);
            insertModuleQuery = [insertModuleMetaQuery, insertModuleMetaQueryData];
        end        
    end
end