

classdef SqliteDatabase < org.dataone.client.sqlite.Database
    
    properties (SetAccess = protected)
        JDBC_SQLITE_DRIVER
        DB_URL
        userName
        password
        dbName
        dbConn
    end
    
    methods
        
        function this = SqliteDatabase(varargin)
            this = this@org.dataone.client.sqlite.Database(varargin{:});
            this.openDBConnection();
        end
        
        function db_conn = openDBConnection(sqldb_obj, configOptions)
          
            try
                sqldb_obj.dbConn = database(sqldb_obj.dbName, sqldb_obj.userName, sqldb_obj.password, sqldb_obj.JDBC_SQLITE_DRIVER, sqldb_obj.DB_URL);
                db_conn = sqldb_obj.dbConn;                
            catch runtimeError
                error_message = ...
                    [error_message ' ' ...
                    runtimeError.message];
                error(['There was an error trying to connect to the sqlite database: ' ...
                    char(10) ...
                    error_message]);
            end            
        end
                
        function count = getTable(sqldb_obj, table_name)
            
            sqldb_obj.openDBConnection();
            sql_statement = sprintf('SELECT count(*) FROM sqlite_master WHERE type= "table" AND name="%s"', table_name);
                       
            curs = exec(sqldb_obj.dbConn, sql_statement);          
            curs = fetch(curs);
            count = rows(curs);
            
            % Disconnect the database connection
            close(curs);
            sqldb_obj.closeDBConnection();
        end
        
        
        function closeDBConnection(sqldb_obj)
            close(sqldb_obj.dbConn);
        end
        
        function result = execute(sqldb_obj, sql_statement, tableName)
            
            setdbprefs('DataReturnFormat','cellarray');
            
            % Get the database connection and check if the table
            % exists
            count = sqldb_obj.getTable(tableName);
            
            if count >= 1
                sqldb_obj.openDBConnection();
                
                curs = exec(sqldb_obj.dbConn, sql_statement);
                
                if curs.ResultSet ~= 0 
                    % for select query (changed on 080816)
                    curs = fetch(curs);                   
                    if rows(curs) == 0
                        result = [];
                    else
                        result = curs.Data;
                    end
                else
                    % for the insert query (changed on 080816)
                    result = curs.Data;
                end
                
                % Disconnect the database connection
                close(curs);
                sqldb_obj.closeDBConnection();
            end
        end
  
    end
    
end
