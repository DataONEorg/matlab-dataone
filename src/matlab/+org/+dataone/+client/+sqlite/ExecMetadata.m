classdef ExecMetadata < hgsetget
    
   properties
       % The unique identifier for this execution
       executionId;
       % The unique identifier for the associated metadata object
       metadataId;
       % The text string associated with this execution
       tag;
       % The unique identifier for this execution that is meaningful for a user 
       datapackageId;
       % The user name who ran this execution
       user;
       % The user identity who uploaded the package
       subject;
       % The host identifier to which the package was uploaded
       hostId;
       % The starting time of this execution
       startTime;
       % The operating system name
       operatingSystem;
       % ???
       runtime;
       % ???
       softwareApplication;
       % The modules information used by the software application      
       moduleDependencies;
       % The ending time of this execution
       endTime;
       % The error message captured during this execution
       errorMessage;
       % The timestamp that the data package for this execution was
       % uploaded to a repository
       publishTime;
       % The node name that the execution was published to
       publishNodeId;
       % The identifier for the uploaded data package
       publishID;
       % a logical variable that indicates whether this was a console
       % session
       console;
       % A simple integer value associated with this execution
       seq;
   end
   
   properties (Access = private)
       
   end
   
   methods (Access = private)
       
   end
   
   
   methods
       function execMetadata = ExecMetadata(varargin)
           % EXECMETADATA Initialize an execution metadata object
           
       end
       
       function createExecMetaTable()
           % CREATEEXECMETATABLE Create an execution metadata table
           
           db_conn = database('prov.db', '', '', 'org.sqlite.JDBC', 'jdbc:sqlite:/Users/syc/Documents/matlab-dataone/prov.db');
           
           create_statement = ['create table execmeta' ...
               '(' ...
               'seq INTEGER PRIMARY KEY,' ...
               'executionId TEXT not null,' ...
               'metadataId TEXT,' ...
               'datapackageId TEXT,' ...
               'user TEXT,' ...
               'subject TEXT,' ...
               'hostId TEXT,' ...
               'startTime TEXT,' ...
               'operatingSystem TEXT,' ...
               'runtime TEXT,' ...
               'softwareApplication TEXT,' ...
               'moduleDependencies TEXT,' ...
               'endTime TEXT,' ...
               'errorMessage TEXT,' ...
               'publishTime TEXT,' ...
               'publishNodeId TEXT,' ...
               'publishId TEXT,' ...
               'console INTEGER,' ...
               'unique(executionId));'];
           
            curs=exec(db_conn, create_statement);
            
            close(db_conn);
       end
       
       function result = writeExecMeta(varargin)
           % WRITEEXECMETA Save a single execution metadata
           
           
       end
       
       function result = updateExecMeta(varargin)
           % UPDATEEXECMETA Update a single execution metadata object
        
           
       end
       
       function result = readExecMeta(varargin)
           % READEXECMETA Retrieve saved execution metadata
          
           
       end
   end
   
     
end