classdef Database < handle
    properties (Abstract = true, SetAccess = protected)
        JDBC_SQLITE_DRIVER
        DB_URL
        userName
        password
        dbName
    end
    
    methods
        function this = Database(varargin)
            switch nargin
                case 1
                    this.dbName = varargin{1}.db_name;
                    this.userName = varargin{1}.user_name;
                    this.password = varargin{1}.password;
                    this.JDBC_SQLITE_DRIVER = varargin{1}.jdbc_sqlite_driver;
                    this.DB_URL = varargin{1}.db_url;
                    
                case 5
                    this.dbName = varargin{1};
                    this.userName = varargin{2};
                    this.password = varargin{3};
                    this.JDBC_SQLITE_DRIVER = varargin{4};
                    this.DB_URL = varargin{5};
                    
                otherwise
                    throw(MException('Database:error', 'invalid options'));
            end
        end
    end

end