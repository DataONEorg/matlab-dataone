classdef SqliteDatabase < org.dataone.client.sqlite.Database 
    % SQLITEDATABASE This class defines the attributes and methods that a
    % matlab can interactive with a sqlite database.
    % 
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
            setdbprefs('DataReturnFormat','cellarray');
        end
        
        function db_conn = openDBConnection(sqldb_obj, configOptions)         
            try
                sqldb_obj.dbConn = database(sqldb_obj.dbName, sqldb_obj.userName, sqldb_obj.password, sqldb_obj.JDBC_SQLITE_DRIVER, sqldb_obj.DB_URL);
                db_conn = sqldb_obj.dbConn;   
                % Set the PRAGMA values (enable foreign key) to the
                % proveannce database 
                exec(db_conn, 'PRAGMA foreign_keys = ON;');
            catch runtimeError
                error_message = ...
                    [error_message ' ' ...
                    runtimeError.message];
                error(['There was an error trying to connect to the sqlite database: ' ...
                    char(10) ...
                    error_message]);
            end            
        end
        
        function closeDBConnection(sqldb_obj)
            close(sqldb_obj.dbConn);
        end
        
        function count = getTable(sqldb_obj, table_name)
            sql_statement = sprintf('SELECT count(*) FROM sqlite_master WHERE type= "table" AND name="%s"', table_name);
            curs = exec(sqldb_obj.dbConn, sql_statement);
            curs = fetch(curs);
            count = rows(curs);
            close(curs);
        end
                
        function result = execute(sqldb_obj, sql_statement, varargin)
  
            curs = exec(sqldb_obj.dbConn, sql_statement);
            
            if curs.ResultSet ~= 0
                % for select query 
                curs = fetch(curs);
                if rows(curs) == 0
                    result = [];
                else
                    result = curs.Data;
                end
            else
                % for the insert query 
                result = curs.Data;
            end
            
            close(curs);         
        end       
    end   
end