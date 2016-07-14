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
       publishId;
       % a logical variable that indicates whether this was a console
       % session
       console;
       % A simple integer value associated with this execution
       seq;
       % The table name
       tableName;
   end
   
   properties (Access = private)
       
   end
   
   methods (Static)
       function create_statement = createExecMetaTable()
           % CREATEEXECMETATABLE Create an execution metadata table
           
           create_statement = ['create table execmeta' ...
               '(' ...
               'executionId TEXT PRIMARY KEY not null,' ...
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
       end
       
             
       function result = readExecMeta(varargin)
           % READEXECMETA Retrieve saved execution metadata
           
           
       end
   end
   
   
   methods
       function this = ExecMetadata(varargin)
           % EXECMETADATA Initialize an execution metadata object
           
           switch nargin
               case 1
                   this.executionId = varargin{1}.execution_id;
                   this.metadataId = varargin{1}.metadata_id;
                   this.tag = varargin{1}.tag;
                   this.datapackageId = varargin{1}.datapackage_id;
                   this.user = varargin{1}.user;
                   this.subject = varargin{1}.subject;
                   this.hostId = varargin{1}.host_id;
                   this.startTime = varargin{1}.start_time;
                   this.operatingSystem = varargin{1}.operating_system;
                   this.runtime = varargin{1}.run_time;
                   this.softwareApplication = varargin{1}.software_application;
                   this.moduleDependencies = varargin{1}.module_dependencies;
                   this.endTime = varargin{1}.end_time;
                   this.errorMessage = varargin{1}.error_message;
                   this.publishTime = varargin{1}.publish_time;
                   this.publishNodeId = varargin{1}.publish_node_id;
                   this.publishId = varargin{1}.publish_id;
                   this.console = varargin{1}.console;
                   
               case 18
                   this.executionId = varargin{1};
                   this.metadataId = varargin{2};
                   this.tag = varargin{3};
                   this.datapackageId = varargin{4};
                   this.user = varargin{5};
                   this.subject = varargin{6};
                   this.hostId = varargin{7};
                   this.startTime = varargin{8};
                   this.operatingSystem = varargin{9};
                   this.runtime = varargin{10};
                   this.softwareApplication = varargin{11};
                   this.moduleDependencies = varargin{12};
                   this.endTime = varargin{13};
                   this.errorMessage = varargin{14};
                   this.publishTime = varargin{15};
                   this.publishNodeId = varargin{16};
                   this.publishId = varargin{17};
                   this.console = varargin{18};
               otherwise
                   throw(MException('ExecMetadata:error', 'invalid options'));
           end           
       end
       
      
       function insertQuery = writeExecMeta(execMetadata)
           % WRITEEXECMETA Save a single execution metadata
           
           import org.dataone.client.sqlite.SqliteDatabase;
                     
           execemeta_colnames = {'executionId', 'metadataId', 'tag', ...
               'datapackageId', 'user', 'subject', 'hostId', 'startTime', ...
               'operatingSystem', 'runtime', 'softwareApplication', 'moduleDependencies', ...
               'endTime', 'errorMessage', 'publishTime', 'publishNodeId', 'publishId', 'console'};
           
           data_row = cell(1, length(execemeta_colnames));
           for i = 1:length(execemeta_colnames)
               data_row{i} = execMetadata.get(execemeta_colnames{i});
           end
           
           % construct a SQL INSERT statement for fast insert
           insertQuery = sprintf('insert into %s (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) values ', execMetadata.tableName, execemeta_colnames{:});
           insertQueryData = sprintf('("%s","%s","%s","%s",%s,"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",%d);', data_row{:});
           insertQuery = [insertQuery , insertQueryData];
           
       end
       
       function result = updateExecMeta(varargin)
           % UPDATEEXECMETA Update a single execution metadata object
        
           
       end
   end
   
     
end