

classdef SqliteHelper < hgsetget
    
    properties
        dbName;
        dbConn;
    end
    
    methods
        
        function sqldb_obj = SqliteHelper(db_name)
            sqldb_obj.dbName = db_name;
            sqldb_obj.openDBConnection();
        end
        
        function db_conn = openDBConnection(sqldb_obj, configOptions)
            
            JDBC_SQLITE_DRIVER = 'org.sqlite.JDBC';
            DB_URL = 'jdbc:sqlite:/Users/syc/Documents/matlab-dataone/prov.db';
            USER = '';
            PASS = '';
            error_message = '';
            
            try
                sqldb_obj.dbConn = database(sqldb_obj.dbName, USER, PASS, JDBC_SQLITE_DRIVER, DB_URL);
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
        
        
        function curs = getTable(sqldb_obj, sql_statement)
            curs = exec(sqldb_obj.dbConn, sql_statement);
        end
        
        
        function closeDBConnection( )
            close(sqldb_obj.dbConn);
        end
        
    end
    
end
