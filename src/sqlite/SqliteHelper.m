classdef SqliteHelper < hgsetget
    properties
       dbconn; 
    end
    
    methods
        function db_conn = openDBConnection(sqlhelper, dbname)

            JDBC_SQLITE_DRIVER = 'org.sqlite.JDBC';
            DB_URL = 'jdbc:sqlite:/Users/syc/Documents/matlab-dataone/prov.db';
            USER = '';
            PASS = '';

            sqlhelper.db_conn = NULL;
            error_message = '';
            
            try 
                sqlhelper.db_conn = database(dbname, USER, PASS, JDBC_SQLITE_DRIVER, DB_URL);
                db_conn = sqlhelper.db_conn;
                
            catch runtimeError 
                error_message = ...
                    [error_message ' ' ...
                    runtimeError.message];
                error(['There was an error trying to connect to the sqlite database: ' ...
                    char(10) ...
                    runtimeError.message]);
            end

        end
        
        function dbconn = openDBConnection(sqlhelper, dbname, connectionOpts)
            
        end
        
        function closeDBConnection(sqlhelper, dbconn)
            close(sqlhelper.db_conn);
        end
        
        function dispose()
            
        end
        
        function curs = getTable(sqlhelper, sql_statement)
            curs = exec(sqlhelper.db_conn, sql_statement); 
        end
    end
    
end
