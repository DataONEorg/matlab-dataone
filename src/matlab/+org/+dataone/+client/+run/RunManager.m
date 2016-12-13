% RUNMANAGER A class used to track information about program runs.
%   The RunManager class provides functions to manage script runs in terms
%   of the known file inputs and the derived file outputs. It keeps track
%   of the provenance (history) relationships between these inputs and outputs.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2016 DataONE

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%   
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef RunManager < hgsetget

    properties      
        % The instance of the Configuration class used to provide settings details for this RunManager
        configuration;
                
        % The execution metadata associated with this run
        execution;
      
        % The generated workflow object built by YesWorkflow 
        workflow;
        
        % A database storing the prospective and retrospective provenance information
        provenanceDB;
               
    end

    properties (Access = private)     
        % Enable or disable the provenance capture state
        prov_capture_enabled = false;

        % The state of a recording session
        recording = false;
        
        % The DataPackage aggregating and describing all objects in a run
        dataPackage;
       
        processViewDotFileName = '';
        dataViewDotFileName = '';
        combinedViewDotFileName = '';
        
        processViewPdfFileName = '';
        dataViewPdfFileName = '';
        combinedViewPdfFileName = '';
        
        wfMetaFileName = '';

        % DataONE CN URI resolve endpoint 
        D1_CN_Resolve_Endpoint;
        
        % Current workflow identifier
        wfIdentifier;
        
        % Predicate for the rdf:type
        aTypePredicate;
        
        % Current association instance URI
        associationSubjectURI;
        
        % Current user URI
        userURI;
        
        % Predicate for provone: Data
        provONEdataURI;
        
        % The YesWorkflow Extractor object
        extractor;
        
        % The YesWorkflow Modeler object
        modeler;
        
        % The YesWorkflow Grapher object
        grapher;
                    
        last_sequence_number;
        
        % A flag for interactive mode or not
        console = true; 
        
        DEFAULT_QUERY_ENGINE = 'XSB'; % 11-14-16
    end
   
    methods (Access = private)

        function manager = RunManager(configuration)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            % The RunManager class manages outputs of a script based on the
            % settings in the given configuration passed in.
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.sqlite.Database;
            import org.dataone.client.sqlite.SqliteDatabase;
            import org.dataone.client.sqlite.ExecMetadata;
            import org.dataone.client.sqlite.FileMetadata;
            import org.dataone.client.sqlite.ModuleMetadata;
            import org.dataone.client.sqlite.ExecModuleBridge;
            
            warning('off','backtrace');
            
            manager.configuration = configuration;
            
            % Configure the provenance database
            db_path = manager.configuration.provenance_storage_directory;
            db_file = 'recordm.sqlite'; 
            db_url = sprintf('jdbc:sqlite:%s/%s', db_path, db_file);
            manager.provenanceDB = SqliteDatabase(db_file, '', '', 'org.sqlite.JDBC', db_url);
       
            create_exec_meta_table_statement = ExecMetadata.createExecMetaTable('execmeta');
            create_tag_table_statement = ExecMetadata.createTagTable('tags');
            create_file_meta_table_statement = FileMetadata.createFileMetadataTable('filemeta');
            create_module_meta_table_statement = ModuleMetadata.createModuleMetaTable('modulemeta');
            create_bridge_table_statement = ExecModuleBridge.createExecModuleBridgeTable('execmodulebridge');

            manager.provenanceDB.execute(create_exec_meta_table_statement, 'execmeta');
            manager.provenanceDB.execute(create_tag_table_statement, 'tags');
            manager.provenanceDB.execute(create_file_meta_table_statement, 'filemeta');
            manager.provenanceDB.execute(create_module_meta_table_statement, 'modulemeta');
            manager.provenanceDB.execute(create_bridge_table_statement, 'execmodulebridge');
            
            archive_dir = sprintf('%s/archive', manager.configuration.provenance_storage_directory);
            if ~exist(archive_dir, 'dir' )
                mkdir(archive_dir);
            end
            
            manager.init();  
            mlock; % Lock the RunManager instance to prevent clears          
        end
                
        function predicate = asPredicate(runManager, property, prefix)
            % ASPREDICATE  Given a Jena Property and namespace prefix, create an ORE Predicate. 
            % This allows us to use the Jena vocabularies.
            %   property -- ore predicate
            %   prefix -- namespace prefix
            import com.hp.hpl.jena.rdf.model.Property;
            import org.dspace.foresite.Predicate;
            import java.net.URI;
            import com.hp.hpl.jena.vocabulary.RDF;
            import java.lang.String;
            
            predicate = Predicate();
            if runManager.configuration.debug
                fprintf('property.localName = %s\n', char(property.getLocalName()));           
            end
         
            predicate.setName(property.getLocalName());
            
            import org.dataone.util.JenaPropertyUtil;
    
            prop = JenaPropertyUtil.getType(property);
            ns = JenaPropertyUtil.getNameSpace(property);
            predicate.setNamespace(ns);         
            %predicate.setNamespace(property.getNamespace()); % There is an error here !
            
            if isempty(prefix) ~= 1
                predicate.setPrefix(prefix);               
            end
            predicate.setURI(URI(property.getURI()));
            
            if runManager.configuration.debug
                fprintf('predicate.URI = %s\n', char(predicate.getURI()));
                fprintf('predicate.nameSpace = %s\n', char(predicate.getNamespace()));
            end
        end
                
        function [certificate, standardizedName] = getCertificate(runManager)
            % GETCERTIFICATE Gets a certificate 
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
            
            % Get a certificate for the Root CA           
            certificate = CertificateManager.getInstance().loadCertificate();          
            if ~isempty(certificate)
                dn = CertificateManager.getInstance().getSubjectDN(certificate).toString();
                standardizedName = char(CertificateManager.getInstance().standardizeDN(dn)); % convert java string to char nov-2-2015
            else
                standardizedName = '';
            end
        end
                        
        function configYesWorkflow(runManager, scriptPath)
            % CONFIGYESWORKFLOW Set YesWorkflow extractor language model to be Matlab type
            % Default configuration is used now.
            
            import org.yesworkflow.extract.DefaultExtractor;
            import org.yesworkflow.model.DefaultModeler;
            import org.yesworkflow.graph.DotGrapher;
            import java.io.PrintStream;
            import org.yesworkflow.db.YesWorkflowDB;
            
            ywdb = YesWorkflowDB.createInMemoryDB();
                       
            runManager.extractor = DefaultExtractor(ywdb);
            runManager.modeler = DefaultModeler(ywdb);
            runManager.grapher = DotGrapher(java.lang.System.out, java.lang.System.err);
            
            % Configure yesWorkflow language model to be Matlab
            import org.dataone.util.HashmapWrapper;
            import org.yesworkflow.Language;
            
            config = HashmapWrapper;
            config.put('language', Language.MATLAB);
            runManager.extractor = runManager.extractor.configure(config);         
          
            % Set generate_workflow_graphic to be true
            runManager.configuration.generate_workflow_graphic = true;
            
        end
                
        function captureProspectiveProvenanceWithYW(runManager, runDirectory)
            % CAPTUREPROSPECTIVEPROVENANCEWITHYW captures the prospective provenance using YesWorkflow 
            % by scannning the inline yesWorkflow comments.
         
            import java.io.BufferedReader;
            import org.yesworkflow.annotations.Annotation;
            import org.yesworkflow.model.Program;
            import org.yesworkflow.model.Workflow;
            import java.io.FileInputStream;
            import java.io.InputStreamReader;
            import java.util.List;
            import java.util.HashMap;
            import org.yesworkflow.config.YWConfiguration;
            import org.yesworkflow.model.DefaultModeler;
            
            try
                           
                % Read script content from disk
                in = FileInputStream(runManager.execution.software_application);
                reader = BufferedReader(InputStreamReader(in));
                
                % Use yw.properties for configuration
                config = YWConfiguration();
                
                % Call YW-Extract module
                runManager.extractor = runManager.extractor.reader(reader);
                annotations = runManager.extractor.extract().getAnnotations();
                
                % Call YW-Model module
                runManager.modeler = runManager.modeler.annotations(annotations);
                runManager.modeler = runManager.modeler.model();
                runManager.workflow = runManager.modeler.getModel().program;
               
                % Call YW-Graph module
                if runManager.configuration.generate_workflow_graphic
                    import org.yesworkflow.graph.GraphView;
                    import org.yesworkflow.graph.CommentVisibility;
                    import org.dataone.util.HashmapWrapper;
                    import org.yesworkflow.graph.LayoutDirection;
                    
                    runManager.grapher = runManager.grapher.workflow(runManager.workflow);

                    % Generate YW.Process_View dot file  
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.process_view_property_file_name); % Read from process_view_yw.properties                                               
                    runManager.processViewDotFileName = config.get('graph.dotfile');  
                    full_path_processViewDotFileName = [runDirectory filesep runManager.processViewDotFileName];                                              
                    config.set('graph.dotfile', full_path_processViewDotFileName); 
                    runManager.grapher.configure(config.getSection('graph'));
                    runManager.grapher = runManager.grapher.graph();           
                                                         
                    % Generate YW.Data_View dot file                  
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.data_view_property_file_name); % Read from data_view_yw.properties                   
                    runManager.dataViewDotFileName = config.get('graph.dotfile');
                    full_path_dataViewDotFileName = [runDirectory filesep runManager.dataViewDotFileName]; 
                    config.set('graph.dotfile', full_path_dataViewDotFileName);
                    runManager.grapher.configure(config.getSection('graph'));
                    runManager.grapher = runManager.grapher.graph();
                   
                    % Generate YW.Combined_View dot file                   
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.combined_view_property_file_name); % Read from comb_view_yw.properties                    
                    runManager.combinedViewDotFileName = config.get('graph.dotfile');
                    full_path_combinedViewDotFileName = [runDirectory filesep runManager.combinedViewDotFileName];
                    config.set('graph.dotfile', full_path_combinedViewDotFileName);
                    runManager.grapher.configure(config.getSection('graph'));
                    runManager.grapher = runManager.grapher.graph();
                                              
                end  
                
            catch ME 
                error(ME.message);
            end      
        end
        
        function generateYesWorkflowGraphic(runManager, runDirectory)
            % GENERATEYESWORKFLOWGRAPHIC Generates yesWorkflow graphcis in pdf format    
            
            import org.dataone.client.v2.DataObject;
            
            position = strfind(runManager.processViewDotFileName, '.gv'); % get the index of '.gv'            
            processViewDotName = strtrim(runManager.processViewDotFileName(1:(position-1)));
            
            runManager.processViewPdfFileName = [processViewDotName '.pdf'];
            fullPathProcessViewPdfFileName = [runDirectory filesep processViewDotName '.pdf'];
            fullPathProcessViewDotFileName = [runDirectory filesep runManager.processViewDotFileName];
            
            position = strfind(runManager.dataViewDotFileName, '.gv'); % get the index of '.gv'            
            dataViewDotName = strtrim(runManager.dataViewDotFileName(1:(position-1)));
            runManager.dataViewPdfFileName = [dataViewDotName '.pdf'];
            fullPathDataViewPdfFileName = [runDirectory filesep dataViewDotName '.pdf'];
            fullPathDataViewDotFileName = [runDirectory filesep runManager.dataViewDotFileName];
            
            position = strfind(runManager.combinedViewDotFileName, '.gv'); % get the index of '.gv'            
            combViewDotName = strtrim(runManager.combinedViewDotFileName(1:(position-1)));
            runManager.combinedViewPdfFileName = [combViewDotName '.pdf'];
            fullPathCombinedViewPdfFileName = [runDirectory filesep combViewDotName '.pdf'];
            fullPathCombViewDotName = [runDirectory filesep runManager.combinedViewDotFileName];
             
            imageFormatId = 'application/pdf';
           
            % Convert .gv files to .pdf files
            if isunix
                if ismac
                    [status, path] = system('export PATH=${PATH}:/usr/local/bin:/opt/local/bin:~/bin; which dot');
                    path2dot = strtrim(path);
                else
                    [status, path2dot] = system('which dot');
                    path2dot = strtrim(path2dot);
                end
                
                system([path2dot ' -Tpdf ' fullPathProcessViewDotFileName ' -o ' fullPathProcessViewPdfFileName]);
                system([path2dot ' -Tpdf ' fullPathDataViewDotFileName ' -o ' fullPathDataViewPdfFileName]);
                system([path2dot ' -Tpdf ' fullPathCombViewDotName ' -o ' fullPathCombinedViewPdfFileName]); 
                
            elseif ispc

                dos(['dot -Tpdf ' fullPathProcessViewDotFileName ' -o ' fullPathProcessViewPdfFileName]);
                dos(['dot -Tpdf ' fullPathDataViewDotFileName ' -o ' fullPathDataViewPdfFileName]);
                dos(['dot -Tpdf ' fullPathCombViewDotName ' -o ' fullPathCombinedViewPdfFileName]); 
            else
                disp('Cannot recognize platform');
                
            end
                       
            delete(fullPathProcessViewDotFileName);
            delete(fullPathDataViewDotFileName);
            delete(fullPathCombViewDotName);
            
            % Create D1 object for three yesworkflow images and put
            % them into execution_output_ids array
            comb_image_pid = char(java.util.UUID.randomUUID());
            comb_image_dataObject = DataObject(comb_image_pid, imageFormatId, fullPathCombinedViewPdfFileName);
            runManager.execution.execution_objects(comb_image_dataObject.identifier) = ...
                comb_image_dataObject;
            runManager.execution.execution_output_ids{end+1} = comb_image_pid;
            
            process_image_pid = char(java.util.UUID.randomUUID());
            process_image_dataObject = DataObject(process_image_pid, imageFormatId, fullPathProcessViewPdfFileName);
            runManager.execution.execution_objects(process_image_dataObject.identifier) = ...
                process_image_dataObject;
            runManager.execution.execution_output_ids{end+1} = process_image_pid;
            
            data_image_pid = char(java.util.UUID.randomUUID());
            data_image_dataObject = DataObject(data_image_pid, imageFormatId, fullPathDataViewPdfFileName);
            runManager.execution.execution_objects(data_image_dataObject.identifier) = ...
                data_image_dataObject;
            runManager.execution.execution_output_ids{end+1} = data_image_pid;

        end
                
        function d1Obj = buildD1Object(runManager, fileName, fileFmt, idValue, submitter, mnNodeId)
            % BUILDD1OBJECT build a d1 object for a file on disk.
            %   fileName - the absolute path for a file
            %   fileFmt - the file format defiend in D1
            %   submitter - information for the submitted
            %   mnNodeId - the member node ID
            
            import org.dataone.service.types.v1.Identifier;  
            import org.dataone.client.v1.types.D1TypeBuilder;
            import org.dataone.client.v2.itk.D1Object;
            import javax.activation.FileDataSource;
            import java.io.File;
            
            fileId = File(fileName);
            data = FileDataSource(fileId);
            d1ObjIdentifier = Identifier();
            d1ObjIdentifier.setValue(idValue);
            d1Obj = D1Object(d1ObjIdentifier, data, D1TypeBuilder.buildFormatIdentifier(fileFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId)); 
        end
          
        
        function data_package = buildPackage(runManager, submitter, mnNodeId, dirPath)
            
            import org.dataone.client.v2.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;            
            import org.dataone.util.ArrayListWrapper;
            import org.dataone.client.v2.itk.D1Object;
            import com.hp.hpl.jena.vocabulary.RDF;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import org.dataone.vocabulary.ProvONE_V1;
            import java.net.URI;
            import org.dspace.foresite.ResourceMap;
            import org.dataone.vocabulary.DC_TERMS;
            import org.dataone.vocabulary.ORE;
            import java.math.BigInteger;
            
            import org.dataone.client.v2.DataObject;
            import org.dataone.client.sqlite.FileMetadata;
            import org.dataone.client.sqlite.ExecMetadata;
            
            if runManager.configuration.debug
                disp('====== buildPackage ======');
            end
           
            em_fields = {'seq','executionId','metadataId','datapackageId','user','subject','hostId','startTime','operatingSystem','runtime','softwareApplication','endTime','errorMessage','publishTime','publishNodeId','publishId','console'};
            fm_fields = {'fileId','executionId','filePath','sha256','size','user','modifyTime','createTime','access','format','archivedFilePath'};
            tag_fields = {'seq','executionId','tag'};
            
            % Get the run identifier from the directory name (execution_id)
            path_array = strsplit(dirPath, filesep);
            cur_exec_id = char(path_array(end)); 
                                 
            % Query the ExecMetadata table using the given execution_id
            % 080116            
            read_exec_query = sprintf('select * from %s e where e.executionId="%s";', 'execmeta', cur_exec_id);            
            row_exec_meta = runManager.provenanceDB.execute(read_exec_query, 'execmeta');
            row_exec_meta_struct = cell2struct(row_exec_meta, em_fields, 2);
            if isempty(row_exec_meta)               
                warning('There is no record for the %s in the %s table', cur_exec_id, 'execmeta');
            else
                % The following information are required by EML.update()
                runManager.execution.start_time = row_exec_meta_struct.startTime; % get the value of startTime
                runManager.execution.software_application = row_exec_meta_struct.softwareApplication; % get the value of sofware_application 
                runManager.execution.execution_id = cur_exec_id; 
            end
            
            % Get the identifier for the script file object from the
            % filemeta table by searching for "access='execute'"             
            program_id = '';
            program_metadata_obj = FileMetadata('', cur_exec_id, '','',0,'','','','execute','',''); 
            read_program_query = program_metadata_obj.readFileMeta('','');
            rows_program_meta = runManager.provenanceDB.execute(read_program_query, program_metadata_obj.tableName);
            rows_program_meta_struct = struct;
            if ~isempty(rows_program_meta)
                rows_program_meta_struct = cell2struct(rows_program_meta, fm_fields, 2);               
                program_id = rows_program_meta_struct.fileId;
            end
        
            % Initialize a dataPackage to manage the run
            packageIdentifier = Identifier();            
            packageIdentifier.setValue(runManager.execution.execution_id);      
           
            % Create a resourceMap identifier
            resourceMapId = Identifier();
            resourceMapId.setValue(['resourceMap_' ...
                runManager.execution.execution_id '.rdf']);

            % Create an empty datapackage with resourceMapId
            import org.dataone.configuration.Settings;
            Settings.getConfiguration().setProperty( ...
                'D1Client.CN_URL', ...
                runManager.configuration.coordinating_node_base_url);
            runManager.dataPackage = DataPackage(resourceMapId);
            
            % Get the base URL of the DataONE coordinating node server
            runManager.D1_CN_Resolve_Endpoint = ...
                [char(runManager.configuration.coordinating_node_base_url) '/v2/resolve/'];
            
            % Because of the hard-coded 'v1' in ResourceMapFactory, we need
            % this separate endpoint for inserting
            % ore:aggregates/isAggregatedBy relationships
            resource_map_resolve_endpoint = ...
                [char(runManager.configuration.coordinating_node_base_url) '/v1/resolve/'];
            
            runManager.provONEdataURI = URI(ProvONE.Data.getURI());
            runManager.aTypePredicate = runManager.asPredicate(RDF.type, 'rdf');
            provOneProgramURI = URI(ProvONE.Program.getURI());            
            
            % Build predicates and subject/object URIs for later use
            hadPlanPredicate = PROV.predicate('hadPlan');
            provAssociationURI = URI(PROV.Association.getURI());
            qualifiedAssociationPredicate = PROV.predicate('qualifiedAssociation');
            provOneExecURI = URI(ProvONE.Execution.getURI()); 
            wasDerivedFromPredicate = PROV.predicate('wasDerivedFrom');
            wasAssociatedWithPredicate = PROV.predicate('wasAssociatedWith');
            wasGeneratedByPredicate = PROV.predicate('wasGeneratedBy');
            agentPredicate = PROV.predicate('agent');
            provONEUserURI = URI(ProvONE.User.getURI());                                                
            runManager.execution.execution_uri = ...
                URI([runManager.D1_CN_Resolve_Endpoint  ...
                'execution_' runManager.execution.execution_id]);
            runManager.associationSubjectURI = ...
                URI([runManager.D1_CN_Resolve_Endpoint ...
                'association_' char(java.util.UUID.randomUUID())]);
            usedPredicate = PROV.predicate('used');
            aggregatesPredicate = ORE.predicate('aggregates');
            isAggregatedByPredicate = ORE.predicate('isAggregatedBy');
            
            % Create a DataObject for the program that we are running and
            %    update the resulting sysmeta in the stored exucution
            %    matlab DataObject 080116
            programD1JavaObj = runManager.buildD1Object( ...
                rows_program_meta_struct.filePath, rows_program_meta_struct.format, ...
                rows_program_meta_struct.fileId, submitter, mnNodeId);
            runManager.dataPackage.addData(programD1JavaObj);
                       
            % Create a D1 identifier for the workflow script  
            runManager.wfIdentifier = Identifier();     
            runManager.wfIdentifier.setValue(rows_program_meta_struct.fileId);

            % The workflow program URI
            programURI = URI([runManager.D1_CN_Resolve_Endpoint ...
                char(runManager.wfIdentifier.getValue())]);
            % The resource map aggregation URI
            aggregationId = [char(resourceMapId.getValue()) '#aggregation'];
            aggregationURI = URI([resource_map_resolve_endpoint ...
                aggregationId]);
            
            % Add the program to the aggregation (We have to do this
            % explicitly because DataPackage.addData() only adds to a
            % hashmap that later gets added to resource map at serialize
            % time
            runManager.dataPackage.insertRelationship( ...
                aggregationURI, ...
                aggregatesPredicate, ...
                programURI);

            runManager.dataPackage.insertRelationship( ...
                programURI, ...
                isAggregatedByPredicate, ...
                aggregationURI);

            runManager.dataPackage.insertRelationship( ...
                programURI, ...
                runManager.aTypePredicate, ...
                provOneProgramURI);

            % Record the prov relationship: association->prov:hadPlan->program
            runManager.dataPackage.insertRelationship( ...
                runManager.associationSubjectURI, ...
                hadPlanPredicate, ...
                programURI);

            % Record the prov relationship: 
            % execution->prov:qualifiedAssociation->association
            runManager.dataPackage.insertRelationship( ...
                runManager.execution.execution_uri, ...
                qualifiedAssociationPredicate, ...
                runManager.associationSubjectURI);

            % Record relationship identifying association id as a prov:Association
            runManager.dataPackage.insertRelationship( ...
                runManager.associationSubjectURI, ...
                runManager.aTypePredicate, ...
                provAssociationURI);
                        
            % Record relationship identifying execution id as a provone:Execution 
            runManager.dataPackage.insertRelationship(...
                runManager.execution.execution_uri, ...
                runManager.aTypePredicate, ...
                provOneExecURI);  
                      
            % Store the ProvONE relationships for user
            runManager.userURI = URI([runManager.D1_CN_Resolve_Endpoint ...
                runManager.execution.account_name]);                 
            
            % Record the relationship between the Execution and the user
            runManager.dataPackage.insertRelationship( ...
                runManager.execution.execution_uri, ...
                wasAssociatedWithPredicate, ...
                runManager.userURI);    
            
            % Record the relationship for association->prov:agent->"user"
            runManager.dataPackage.insertRelationship( ...
                runManager.associationSubjectURI, ...
                agentPredicate, ...
                runManager.userURI);
            
            % Record a relationship identifying the provONE:user
            runManager.dataPackage.insertRelationship( ...
                runManager.userURI, ...
                runManager.aTypePredicate, ...
                provONEUserURI); 

            % Create a science metadata object and add it to the package
            metadata_file_base_name = ['metadata_' runManager.execution.execution_id '.xml'];
            metadataExists = exist(fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', ...
                runManager.execution.execution_id, ...
                metadata_file_base_name), 'file') == 2;
            
            if ( ~ metadataExists )
                import org.ecoinformatics.eml.EMLDataset;
                emlDataset = EMLDataset();                
            end
            
            scienceMetadataIdStr = ['metadata_' ...
                runManager.execution.execution_id '.xml'];
            scienceMetadataId = Identifier();
            scienceMetadataId.setValue(scienceMetadataIdStr);
            
            % Update the science metadata with configured fields
            if ( ~ metadataExists )
                emlDataset.update( ...
                    runManager.configuration, runManager.execution);
            end
            
            % Update the EML science metadata with the program (script) entity
            [path, file_name, ext] = fileparts(rows_program_meta_struct.filePath);
            program_file_metadata = dir(rows_program_meta_struct.filePath);

            if ( ~ metadataExists )
                emlDataset.appendOtherEntity([], [file_name ext], [], ...
                    [file_name ext], program_file_metadata.bytes, ...
                    rows_program_meta_struct.fileId, ...
                    [runManager.D1_CN_Resolve_Endpoint ...
                    rows_program_meta_struct.fileId], ...
                    rows_program_meta_struct.format);                
            end
           
            % Associate the science metadata with the program in the
            % aggregation
            import org.dataone.util.ArrayListWrapper;
            
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.IOUtils;
            
            programList = ArrayListWrapper();
            programList.add(runManager.wfIdentifier);
                
            runManager.dataPackage.insertRelationship( ...
                scienceMetadataId, programList);

            % Find the execution_output_ids and execution_input_ids lists
            % 080216
            runManager.execution.execution_input_ids = {};
            runManager.execution.execution_output_ids = {};
            
            read_files_metadata = FileMetadata('', runManager.execution.execution_id, '','','','','','', 'read','',''); %103116
            read_files_query = read_files_metadata.readFileMeta('', '');
            read_files_array = runManager.provenanceDB.execute(read_files_query, read_files_metadata.tableName);
            if ~isempty(read_files_array)
                runManager.execution.execution_input_ids = read_files_array(:, 1);
            end
            
            write_files_metadata = FileMetadata('', runManager.execution.execution_id, '','','','','','', 'write','',''); %103116
            write_files_query = write_files_metadata.readFileMeta('', '');
            write_files_array = runManager.provenanceDB.execute(write_files_query, write_files_metadata.tableName);
            if ~isempty(write_files_array)
                runManager.execution.execution_output_ids = write_files_array(:, 1);
            end
            
            for i=1:size(write_files_array,1)
                row_out_file_metadata = write_files_array(i,:);
                row_out_fm_struct = cell2struct(row_out_file_metadata, fm_fields, 2);
                
                if runManager.configuration.debug
                    row_out_fm_struct.filePath                   
                end
                
                [path, file_name, ext] = fileparts(row_out_fm_struct.filePath);
                
                j_outputD1Object = runManager.buildD1Object( ...
                    row_out_fm_struct.filePath, row_out_fm_struct.format, ...
                    row_out_fm_struct.fileId, submitter, mnNodeId);
                
                runManager.dataPackage.addData(j_outputD1Object);
                
                j_sysmeta = j_outputD1Object.getSystemMetadata(); % java version sysmeta
                out_file_metadata = dir(row_out_fm_struct.filePath);
                out_file_path_array = strsplit(row_out_fm_struct.filePath, filesep);
                out_file_short_name = char(out_file_path_array(end));
                j_sysmeta.setFileName(out_file_short_name);
                j_sysmeta.setSize(BigInteger.valueOf(out_file_metadata.bytes));
                
                % Update the filemeta file size for new file if the
                % filemeta.size is not equal to the actual file size
                % (12-13-16).
                if row_out_fm_struct.size ~= out_file_metadata.bytes
                    % Recompute the sha256
                    objectFile = File(row_out_fm_struct.filePath);
                    fileInputStream = FileInputStream(objectFile);
                    data = IOUtils.toString(fileInputStream, 'UTF-8');
                    updated_sha256= FileMetadata.getSHA256Hash(data);
                    
                    update_clause = 'UPDATE filemeta ';
                    set_clause = sprintf('SET size=%d, sha256="%s" ', out_file_metadata.bytes, updated_sha256);
                    where_clause = sprintf('WHERE fileId="%s"', row_out_fm_struct.fileId);
                    update_fm_query = sprintf('%s %s %s;', update_clause, set_clause, where_clause);
                    status = runManager.provenanceDB.execute(update_fm_query);                    
                end
                
                %Todo: need to update row_out_file_metadata in the
                %      filemeta table 080216
%                 set(outputDataObject, 'system_metadata', j_sysmeta);
                
                % Update the EML science metadata with the output entity
                if ( ~ metadataExists )
                    emlDataset.appendOtherEntity([], [file_name ext], [], ...
                        [file_name ext], out_file_metadata.bytes, ...
                        row_out_fm_struct.format, ...
                        [runManager.D1_CN_Resolve_Endpoint ...
                        row_out_fm_struct.fileId], ...
                        row_out_fm_struct.format);                    
                end
                
                outSourceURI = URI( ...
                    [runManager.D1_CN_Resolve_Endpoint row_out_fm_struct.fileId]);
                runManager.dataPackage.insertRelationship( ...
                    outSourceURI, ...
                    wasGeneratedByPredicate, ...
                    runManager.execution.execution_uri );
                
                runManager.dataPackage.insertRelationship(...
                    outSourceURI, ...
                    runManager.aTypePredicate, ...
                    runManager.provONEdataURI);
                
                % Record the provone:data->prov:wasDerivedFrom->provone:Data
                % relationship from each input object
                for i=1:size(read_files_array,1)
                    row_in_file_metadata = read_files_array(i,:);
                    row_in_fm_struct = cell2struct(row_in_file_metadata, fm_fields, 2);
                    
                    inSourceURI = ...
                        URI([runManager.D1_CN_Resolve_Endpoint ...
                        row_in_fm_struct.fileId]);
                    runManager.dataPackage.insertRelationship( ...
                        outSourceURI, ...
                        wasDerivedFromPredicate, ...
                        inSourceURI);
                end
            end
            
            % Process execution_input_ids
            for i=1:size(read_files_array,1)
                %    inputId = runManager.execution.execution_input_ids{i};
                row_in_file_metadata = read_files_array(i,:);
                row_in_fm_struct = cell2struct(row_in_file_metadata, fm_fields, 2);
                    
                startIndex = regexp( row_in_fm_struct.fileId, 'http', 'once' );
                if isempty(startIndex)                    
                    [path, file_name, ext] = fileparts(row_in_fm_struct.filePath);
                    
                    j_inputD1Object = runManager.buildD1Object( ...
                        row_in_fm_struct.filePath, row_in_fm_struct.format, ...
                        row_in_fm_struct.fileId, submitter, mnNodeId);
                    
                    runManager.dataPackage.addData(j_inputD1Object);
                    j_sysmeta = j_inputD1Object.getSystemMetadata();
                    in_file_metadata = dir(row_in_fm_struct.filePath);
                    j_sysmeta.setSize(BigInteger.valueOf(in_file_metadata.bytes));
                    in_file_path_array = strsplit(row_in_fm_struct.filePath, filesep);
                    in_file_short_name = char(in_file_path_array(end));
                    j_sysmeta.setFileName(in_file_short_name);
                    
                    %Todo: need to update row_in_file_metadata in the
                    %      filemeta table 080216
%                     set(inputDataObject, 'system_metadata', j_sysmeta);
                    
                    % Update the EML science metadata with the input entity
                    if ( ~ metadataExists )
                        emlDataset.appendOtherEntity([], [file_name ext], [], ...
                            [file_name ext], in_file_metadata.bytes, ...
                            row_in_fm_struct.format, ...
                            [runManager.D1_CN_Resolve_Endpoint ...
                            row_in_fm_struct.fileId], ...
                            row_in_fm_struct.format);                        
                    end
                    
                    inSourceURI = ...
                        URI([runManager.D1_CN_Resolve_Endpoint ...
                        row_in_fm_struct.fileId]);
                    runManager.dataPackage.insertRelationship( ...
                        runManager.execution.execution_uri, ...
                        usedPredicate, ...
                        inSourceURI);
                    
                    runManager.dataPackage.insertRelationship(...
                        inSourceURI, ...
                        runManager.aTypePredicate, ...
                        runManager.provONEdataURI);
                end
            end
            
            % Write the science metadata to the execution directory
            runManager.execution.execution_directory = fullfile(runManager.configuration.provenance_storage_directory, 'runs',runManager.execution.execution_id);
            if ( ~ metadataExists )
                scienceMetadataFile = ...
                    fopen(fullfile( ...
                    runManager.execution.execution_directory, ...
                    scienceMetadataIdStr), 'w');
                if ( scienceMetadataFile == -1 )
                    error('Could not open the science metadata file for writing.');
                    
                end
                
                fprintf(scienceMetadataFile, '%s', emlDataset.toXML());
                fclose(scienceMetadataFile);
            end
            
            % Create the science metadata DataObject
            scienceMetadataDataObject = org.dataone.client.v2.DataObject( ...
                scienceMetadataIdStr, ...
                'eml://ecoinformatics.org/eml-2.1.1', ...
                fullfile( ...
                runManager.execution.execution_directory, ...
                scienceMetadataIdStr));
            
            % Add the science metadata to the Java DataPackage
            scienceMetadataD1JavaObject = runManager.buildD1Object( ...
                scienceMetadataDataObject.full_file_path, ...
                scienceMetadataDataObject.format_id, ...
                scienceMetadataDataObject.identifier, submitter, mnNodeId);
            runManager.dataPackage.addData(scienceMetadataD1JavaObject);
            
            % Update the property "fileName" for the java system metadata.
            % Then, update the matlab system metadata using the java system
            % metadata Dec-4-2015
            j_sysmeta = ...
                scienceMetadataD1JavaObject.getSystemMetadata();
            j_sysmeta.setFileName( ...
                scienceMetadataIdStr); % use base name in system metadata Feb-1-2016
            
            %Todo: need to update row_in_file_metadata in the
            %      filemeta table 080216
%             set(scienceMetadataDataObject, 'system_metadata', j_sysmeta);
            
            % Archive the science metadata file 
            scienceMetadata_full_path = fullfile( ...
                runManager.execution.execution_directory, ...
                scienceMetadataIdStr);
            [archiveRelDir, archivedRelFilePath, db_status] = FileMetadata.archiveFile(scienceMetadata_full_path);
            if db_status == 1
                % The file has not been archived
                full_archive_file_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archivedRelFilePath);
                full_archive_dir_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archiveRelDir);
                if ~exist(full_archive_dir_path, 'dir')
                    mkdir(full_archive_dir_path);
                end
                % Copy this file to the archive directory
                copyfile(scienceMetadata_full_path, full_archive_file_path, 'f');
            end
            
            % Add the science metadata to the filemeta table
            science_metadata = FileMetadata(scienceMetadataDataObject, runManager.execution.execution_id, 'write');
            science_metadata.archivedFilePath = archivedRelFilePath;
            insert_scimeta_query = science_metadata.writeFileMeta();
            status = runManager.provenanceDB.execute(insert_scimeta_query, science_metadata.tableName);
            if status == -1
                message = 'DBError for inserting sciencee metadata file to the filemeta table.';
                error(message);
            end

            % Associate science metadata with the data objects of the
            % package
            import org.dataone.util.ArrayListWrapper;
            inputOutputList = ArrayListWrapper();
            inputOutputIds = union( ...
                runManager.execution.execution_input_ids, ...
                runManager.execution.execution_output_ids);
            
            for idx = 1: length(inputOutputIds)
                inputOutputId = Identifier();
                inputOutputId.setValue(inputOutputIds{idx});
                inputOutputList.add(inputOutputId);               
            end
            
            runManager.dataPackage.insertRelationship(scienceMetadataId, ...
                inputOutputList);
            
            % Serialize a datapackage
            rdfXml = runManager.dataPackage.serializePackage();
            
            % Write to a resourceMap file
            resourceMapName = [char(resourceMapId.getValue())];
            resourceMapFullPath = fullfile( ...
                runManager.execution.execution_directory, ...
                resourceMapName);
            fw = fopen(resourceMapFullPath, 'w');
            if fw == -1, error('Cannot write "%s%".',resourceMapFullPath); end
            fprintf(fw, '%s', char(rdfXml));
            fclose(fw);
            
            % Add resourceMap D1Object to the DataPackage
            resMapFmt = 'http://www.openarchives.org/ore/terms';
            resourceMapD1Object = ...
                runManager.buildD1Object( ...
                resourceMapFullPath, resMapFmt, resourceMapName, submitter, mnNodeId);
            j_sysmeta = resourceMapD1Object.getSystemMetadata();
            j_sysmeta.setFileName(resourceMapName);
            resourceMapD1Object.setSystemMetadata(j_sysmeta);
            
            runManager.dataPackage.addData(resourceMapD1Object);
            
            % Create the resource map DataObject
            resourceMapDataObject = org.dataone.client.v2.DataObject( ...
                char(resourceMapId.getValue()), ...
                resMapFmt, ...
                resourceMapFullPath);
            %Todo: need to update row_in_file_metadata in the
            %      filemeta table 080216
%             set(resourceMapDataObject, 'system_metadata', j_sysmeta);
            
            data_package = runManager.dataPackage;            
        end
               
        
        function saveExecution(runManager, isConsole)
            % SAVEEXECUTION saves the summary of each execution to the
            % execmeta table in the startRecord(): runId,
            % filePath, startTime, endTime, publishedTime, packageId, tag,
            % user, subject, hostId, operatingSystem, runtime, moduleDependencies, 
            % console, errorMessage.
           
            import org.dataone.client.sqlite.ExecMetadata;
            
            runID = char(runManager.execution.execution_id);
            filePath = char(runManager.execution.software_application);
            startTime = char(runManager.execution.start_time);
            endTime = '';
            publishedTime = char(runManager.execution.publish_time);
            packageId = char(runManager.execution.execution_id);
            tag = runManager.execution.tag;                  
            user = char(runManager.execution.account_name);            
            subject = '';
            auth_token = runManager.configuration.get('authentication_token');
            if isempty(auth_token)
                [certificate, standardizedName] = runManager.getCertificate();
                if ~isempty(certificate)
                    runManager.configuration.submitter = standardizedName;
                    subject = strrep(char(standardizedName), ',', ' ');
                end
            else
                subject = '';
            end
            hostId = char(runManager.execution.host_id);
            operatingSystem = char(runManager.execution.operating_system);
            runtime = char(runManager.execution.runtime);            
            publishNodeId = char(runManager.configuration.target_member_node_id);
            errorMessage = '';
            console = isConsole;
            
            % Write execution runtime informaiton to execmeta table in the
            % provenance database 
            exec_obj = ExecMetadata(runID,'',tag,packageId,user,subject,hostId,startTime,operatingSystem,runtime,filePath,endTime,errorMessage,publishedTime,publishNodeId, '', console);
            [insert_exec_query, insert_tag_query] = exec_obj.writeExecMeta();
            status1 = runManager.provenanceDB.execute(insert_exec_query, exec_obj.execTableName);
            status2 = runManager.provenanceDB.execute(insert_tag_query, exec_obj.tagsTableName);
            if (status1 == 0) && (status2 == 0)
                message = 'Insert a record to the ExecMetadata table and Tag table.';
                disp(message);
            else
                errorMessage = [errorMessage, 'SQLiteDatabaseError: Insert record failed.'];
                error(errorMessage);
            end
        end
               
        function updateExecution(runManager, runID)
            % UPDATEEXECUTION updates the summary of each execution to an
            % execution database with the columns: runId,
            % endTime, publishTime, moduleDependencies,
            % errorMessage in the endRecord().
            %   fileName - the name of the execution database
            
            import org.dataone.client.sqlite.ExecMetadata;
            
            endTime = char(runManager.execution.end_time);
            publishedTime = char(runManager.execution.publish_time);
            errorMessage = char(runManager.execution.error_message);
            
            % Write execution runtime informaiton to execmeta table in the
            % provenance database 
            update_clause = 'UPDATE execmeta ';
            set_clause = sprintf('SET endTime="%s", errorMessage="%s", publishTime="%s" ', endTime, errorMessage, publishedTime);
            where_clause = sprintf('WHERE executionId="%s"', runID);
            update_exec_query = sprintf('%s %s %s;', update_clause, set_clause, where_clause);
            status = runManager.provenanceDB.execute(update_exec_query);
           
            if status == 0
                message = 'Update a record to the ExecMetadata table.';
                disp(message);
            else
                errorMessage = [errorMessage, 'SQLiteDatabaseError: Insert record failed.'];
                error(errorMessage);
            end
            
            % Write to modulemeta table and execmodulebridge table for this
            % run 120216
            select_exec_query = sprintf('select e.seq from execmeta e where e.executionId="%s";', runID);
            exec_array = runManager.provenanceDB.execute(select_exec_query, 'execmeta');
            exec_seq = exec_array{1,1};
            moduleDependencies = char(runManager.execution.module_dependencies);
            runManager.processModuleDependencies(moduleDependencies, runID, exec_seq);
        end
        
        function processModuleDependencies(runManager, module_list, runID, execSeq)
            % PROCESSMODULEDEPENDENCIES adds the module dependencies
            % strings to the moduleMetadata table and returns a set of
            % module ids. 120116
            if isempty(module_list)
                return;
            end
                
            import org.dataone.client.sqlite.ModuleMetadata;
        
            if ispc
                module_split_info = strsplit(module_list,';');
            elseif isunix
                module_split_info = strsplit(module_list,':');
            end

            for i=1:length(module_split_info)
                % First, add a record for module_dependency to the modulemeta table if
                % not existed
                module_info = module_split_info{1,i};
                select_module_query = sprintf('select count(*) from modulemeta md where md.dependencyInfo=%s', module_info);
                count = runManager.provenanceDB.execute(select_module_query, 'modulemeta');
                if count == 0
                    module_meta = ModuleMetadata(module_info);
                    insert_module_query = module_meta.writeModuleMeta();
                    status = runManager.provenanceDB.execute(insert_module_query, 'modulemeta');
                    if (status ~= 0)
                        errorMessage = 'SQLiteDatabaseError: Insert record failed.';
                        error(errorMessage);
                    end
                end
                % Then, add a (exec_seq, module_id) to the execmodulebridge
                % table               
                select_module_query = sprintf('select md.module_id from modulemeta md where md.dependencyInfo="%s";', module_info);               
                module_dependency_array = runManager.provenanceDB.execute(select_module_query, 'modulemeta');
                if ~isempty(module_dependency_array) 
                    module_id = module_dependency_array{1,1};
                    
                    insert_bridge_query = sprintf('insert into execmodulebridge values ( %d, %d);', execSeq, module_id);
                    status = runManager.provenanceDB.execute(insert_bridge_query, 'execmodulebridge');                    
                    if (status ~= 0)
                        errorMessage = 'SQLiteDatabaseError: Insert record failed.';
                        error(errorMessage);
                    end
                end
            end
        end
        
%         function execMetaMatrix = getExecMetadataMatrix(runManager)
%             
%             % GETEXECMETADATAMATRIX returns a matrix storing the
%             % metadata summary for all executions from the exeucton
%             % database.
%             %   runManager -
%             
%             select_all_query = sprintf('SELECT * from %s;', 'execmeta');
%             exec_metadata_cell = runManager.provenanceDB.execute(select_all_query, 'execmeta');
%             
%             % Convert the cell array to a char matrix (order of columns
%             % changed on 072516)
%             numOfRows = size(exec_metadata_cell, 1);
%             for i=1:numOfRows
%                 exec_metadata_cell{i,18} = num2str(exec_metadata_cell{i,18});
%             end
%             
%             execMetaMatrix = exec_metadata_cell;
%             
%             % Todo: Return database table column names
%            
%         end
        
%         function stmtStruct = getRDFTriple(runManager, filePath, p)
%            % GETRDFTRIPLE get all related subjects related to a given property from all
%            % triples contained in a resourcemap.
%            %  filePath - the path to the resourcemap
%            %  p - the given property of a RDF triple
%            
%            import org.dataone.util.NullRDFNode;
%            import org.dataone.vocabulary.PROV;
%            import org.dspace.foresite.Predicate;
%            import com.hp.hpl.jena.graph.Node;
%            import com.hp.hpl.jena.graph.Triple;
%            import com.hp.hpl.jena.rdf.model.Model;
%            import com.hp.hpl.jena.rdf.model.ModelFactory;
%            import com.hp.hpl.jena.rdf.model.Property;
%            import com.hp.hpl.jena.rdf.model.RDFNode;
%            import com.hp.hpl.jena.rdf.model.Statement;
%            import com.hp.hpl.jena.rdf.model.StmtIterator;
%            import com.hp.hpl.jena.util.FileManager;
%            import java.io.InputStream;
%            import java.util.HashSet;
%            import java.util.ArrayList;
%            
%            % Read the RDF/XML file
%            fm = FileManager.get();
%            in = fm.open(filePath);          
%            if isempty(in) == 1 
%                error('File: %s not found.', filePath);
%            end         
%            model = ModelFactory.createDefaultModel(); % Create an empty model
%            model.read(in, '');
%            queryPredicate= model.createProperty(p.getNamespace(), p.getName());
%            stmts = model.listStatements([], queryPredicate, NullRDFNode.nullRDFNode); % null, (RDFNode)null
%            
%            i = 1;
%            while (stmts.hasNext()) 
% 	            s = stmts.nextStatement();
% 	       	    t = s.asTriple();        
%                 
%                 % Create a table for files to be published in a datapackage 
%                 if t.getSubject().isURI()
%                     stmtStruct(i,1).Subject = char(t.getSubject().getLocalName());
%                 elseif t.getSubject().isBlank()
%                     stmtStruct(i,1).Subject = char(t.getSubject().getBlankNodeId());
%                 else
%                     stmtStruct(i,1).Subject = char(t.getSubject().getName());
%                 end
%                 
%                 stmtStruct(i,1).Predicate = char(t.getPredicate().toString());
%                 
%                 if t.getObject().isURI()
%                     stmtStruct(i,1).Object = char(t.getObject().getLocalName()); % Question: whether it is good to use localName here? In which cases are good?
%                 elseif t.getObject().isBlank()
%                     stmtStruct(i,1).Object = char(t.getObject().getBlankNodeId());
%                 else
%                     stmtStruct(i,1).Object = char(t.getObject().getName());
%                 end
%                 
%                 i = i + 1;
%            end         
%         end
             
%         function [wasGeneratedByStruct, usedStruct, hadPlanStruct, qualifiedAssociationStruct, wasAssociatedWithPredicateStruct, userList, rdfTypeStruct] = getRelationships(runManager)
%            % GETRELATIONSHIPS get the relationships from the resourceMap
%            % including prov:used, prov:hadPlan, prov:qualifiedAssociation,
%            % prov:wasAssociatedWith, and rdf:type
%             
%            import org.dataone.util.NullRDFNode;
%            import org.dataone.vocabulary.PROV;
%            import org.dspace.foresite.Predicate;
%            import com.hp.hpl.jena.rdf.model.Property;
%            import com.hp.hpl.jena.rdf.model.RDFNode;
%            import com.hp.hpl.jena.vocabulary.RDF;
%            
%            % Query resource map                           
%            resMapFileName = strtrim(ls('*.rdf')); % list the reosurceMap.rdf and remove the whitespace and return characters  
%            wasGeneratedByPredicate = PROV.predicate('wasGeneratedBy');           
%            wasGeneratedByStruct = runManager.getRDFTriple(resMapFileName, wasGeneratedByPredicate);                  
%            
%            usedPredicate = PROV.predicate('used');
%            usedStruct = runManager.getRDFTriple(resMapFileName, usedPredicate); 
%           
%            hadPlanPredicate = PROV.predicate('hadPlan');
%            hadPlanStruct = runManager.getRDFTriple(resMapFileName, hadPlanPredicate); 
%            
%            qualifiedAssociationPredicate = PROV.predicate('qualifiedAssociation');
%            qualifiedAssociationStruct = runManager.getRDFTriple(resMapFileName, qualifiedAssociationPredicate);
%            
%            wasAssociatedWithPredicate = PROV.predicate('wasAssociatedWith');
%            wasAssociatedWithPredicateStruct = runManager.getRDFTriple(resMapFileName, wasAssociatedWithPredicate);
%            userList = wasAssociatedWithPredicateStruct.Object;
%            
%            rdfTypePredicate = runManager.asPredicate(RDF.type, 'rdf');
%            rdfTypeStruct = runManager.getRDFTriple(resMapFileName, rdfTypePredicate);    
%            
%         end       
    end
    
    methods (Static)

        function runManager = getInstance(configuration)
            % GETINSTANCE returns an instance of the RunManager by either
            % creating a new instance or returning an existing one.
            %    mgr = RunManager.getInstance() returns a RunManager object
            %          with the default configuration
            %    mgr = RunManager.getInstance() returns a RunManager object
            %          with the given configuration
                        
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.run.RunManager;
                                  
            warning off MATLAB:dispatcher:nameConflict;
            java.util.logging.LogManager.getLogManager().reset();
             
            % Set the java class path
            RunManager.setMatlabPath();
            
            % Set the overloaded io functions paths
            RunManager.setIOFunctionPath();
            
            warning on MATLAB:dispatcher:nameConflict;

            % Create a default configuration object if one isn't passed in
            if ( nargin < 1 )
                configuration = Configuration.loadConfig('');               
            end
            
            persistent singletonRunManager; % private, stays in memory across clears
            
            if isempty( singletonRunManager )
                import org.dataone.client.run.RunManager;
                runManager = RunManager(configuration);
                singletonRunManager = runManager;               
            else
                runManager = singletonRunManager;
                
            end
        end
                
        function setJavaClassPath()
            % SETJAVACLASSPATH adds all Java libraries found in 
            %   $matlab-dataone/lib to the java class path
            
            % Determine the lib directory relative to the RunManager location
            filePath = mfilename('fullpath');           
            matlab_dataone_dir_array = strsplit(filePath, filesep);           
            matlab_dataone_java_lib_dir = ...
                [strjoin( ...
                    matlab_dataone_dir_array(1:length(matlab_dataone_dir_array) - 7), ...
                    filesep) ...
                    filesep 'lib' filesep 'java' filesep];
            java_libs_array = dir(matlab_dataone_java_lib_dir);
            % For each library file, add it to the class path
            
            classpath = javaclasspath('-all');
            
            for i=3:length(java_libs_array)
                classpathItem = [matlab_dataone_java_lib_dir java_libs_array(i).name];
                presentInClassPath = strmatch(classpathItem, classpath);
                if ( isempty(presentInClassPath) )
                    javaaddpath(classpathItem);
                    disp(['Added new java classpath item: ' classpathItem]);
                end
                
            end
        end
                
        function setMatlabPath()
            % SETMATLABPATH adds all Matlab libraries found in 
            %   $matalab-dataone/lib/matlab to the Matlab path
            
            % Determine the lib directory relative to the RunManager location
            filePath = mfilename('fullpath');         
            matlab_dataone_dir_array = strsplit(filePath, filesep);           
            matlab_dataone_lib_dir = ...
                [strjoin( ...
                    matlab_dataone_dir_array(1:length(matlab_dataone_dir_array) - 7), ...
                    filesep) ...
                    filesep 'lib' filesep 'matlab' filesep];
           
           % Add subdirectories of lib/matlab to the Matlab path,
           addpath(genpath(matlab_dataone_lib_dir));               
        end
                
        function setIOFunctionPath()
            % SETIOFUNCTIONPATH adds all overloaded I/O functions found in 
            %   $matalab-dataone/src/matlab/overloaded_functions/io to the top of Matlab path
            
            % Determine the src directory relative to the RunManager location
            filePath = mfilename('fullpath');         
            matlab_dataone_dir_array = strsplit(filePath, filesep);           
            matlab_dataone_io_dir = ...
                [strjoin( ...
                    matlab_dataone_dir_array(1:length(matlab_dataone_dir_array) - 6), ...
                    filesep) ...
                    filesep 'matlab' filesep 'overloaded_functions' filesep 'io' filesep];
           
           % Add subdirectories of $matalab-dataone/src/matlab/overloaded_functions/io to the Matlab path,          
           addpath(genpath(matlab_dataone_io_dir), '-begin');  
        end        
    end
        
    methods         
        
        function pkg = getDataPackage(runManager)
            % GETDATAPACKAGE returns the Java DataPackage object from the runManager
            
            pkg = runManager.dataPackage;
        end
                
        function d1_cn_resolve_endpoint = getD1_CN_Resolve_Endpoint(runManager)
            % GETD1CNRESOLVEENDPOINT returns the DataONE CN resolve endpoint
            %   from the runManager
            
            d1_cn_resolve_endpoint = runManager.D1_CN_Resolve_Endpoint;
        end
                
        function exec_input_id_list = getExecInputIds(runManager)
            exec_input_id_list = get(runManager.execution, 'execution_input_ids');
        end
                
        function exec_output_id_list = getExecOutputIds(runManager)
            exec_output_id_list = get(runManager.execution, 'execution_output_ids');
        end
             
        function init(runManager)
            % INIT initializes the RunManager instance
                        
            % Ensure the provenance storage directory is configured
            if ( ~ isempty(runManager.configuration) )
                prov_dir = runManager.configuration.get('provenance_storage_directory');
                
                % Only proceed if the runs directory is available
                if ( ~ exist(prov_dir, 'dir') )
                    runs_dir = fullfile(prov_dir, 'runs', filesep);
                    [status, message, message_id] = mkdir(runs_dir);
                    
                    if ( status ~= 1 )
                        error(message_id, [ 'The directory ' runs_dir ...
                              ' could not be created. The error message' ...
                              ' was: ' message]);
                    
                    elseif ( strcmp(message, 'already exists') )
                        if ( runManager.configuration.debug )
                            disp(['The directory ' runs_dir ...
                                ' already exists and will not be created.']);
                        end
                    end                    
                end
                                
                import org.dataone.client.run.Execution;
                
                runManager.execution = Execution();
                runManager.execution.execution_input_ids = {};
                runManager.execution.execution_output_ids = {};
            end
        end
                
        function callYesWorkflow(runManager, scriptPath, dirPath)
            % CALLYESWORKFLOW Records provenance information at the script
            % level using the yesWorkflow tool.
            
           if runManager.configuration.generate_workflow_graphic && runManager.configuration.include_workflow_graphic
                runManager.configYesWorkflow(scriptPath);
                runManager.captureProspectiveProvenanceWithYW(dirPath);
                runManager.generateYesWorkflowGraphic(dirPath);
            end
        end
                
        function data_package = record(runManager, filePath, tag)
            % RECORD Records provenance relationships between data and scripts
            % When record() is called, data input files, data output files,
            % and programs (scripts and classes) are tracked during an
            % execution of the program.
            %    import or.dataone.client.run.RunManager;
            %    mgr = RunManager.getInstance();
            %    mgr.record('path/to/file/to/run', 'optional tag string');
            %
            % A graph of the relationships between the script, its inputs
            % and outputs is produced using the W3C PROV ontology standard 
            % (<http://www.w3.org/TR/prov-o/>) and the
            % DataONE ProvONE model(<https://purl.dataone.org/provone-v1-dev>).
            % Note that, when passing scripts to the record() function,
            % scripts that contain commands such as 'clear all' will cause
            % the recording session to fail because the RunManager instance
            % will have been removed. Also, note that relative path names
            % to files may also cause I/O errors, depending on what your
            % current working directory is at the moment.

            % Return if we are already recording
            if ( runManager.recording )
                return;
            end
            
            import org.dataone.client.run.Execution;
            
            % Set the interactive mode to be false
            runManager.console = false; % Dec-7-2015
            
            % Initialize a new Execution for this run
            runManager.execution = Execution();
            runManager.execution.execution_input_ids = {};
            runManager.execution.execution_output_ids = {};
            all_keys = keys(runManager.execution.execution_objects);
            remove(runManager.execution.execution_objects, all_keys);

            runManager.execution.tag = tag;

            % Do we have a script as input?
            if ( nargin < 2 )
                message = ['Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.'];
                error(message);
            end
            
            % Does the script exist?
            if ( ~exist(filePath, 'file') == 2);
                error([' The script: '  filePath ' does not exist.' ...
                       'Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.']);
            else
                % Set the full path to the script
                try
                    [status, fileAttrs] = fileattrib(filePath);
                    runManager.execution.software_application = fileAttrs.Name;
                catch IOError
                    disp(['There was an error reading: ' ...
                        filePath '. Be sure the file exists in the ' ...
                        'location specified']);
                    rethrow(IOError);   
                end                
            end
            
            % do we have a tag?
            if ( nargin < 3 )
                tag = ''; % otherwise use an empty tag                   
            end
                        
            % Begin collecting execution metadata
            import org.dataone.client.run.Execution;
                
            % Validate the tag, ensuring it can be cast to a string
            try
                tagStr = '';
                if ( ~isempty(tag) )
                    tagStr = cast(tag, 'char');
                end
                
            catch classCastException
                error(['The tag used for the record session cannot be ' ...
                       'cast to a string. Please use a tag label that is ' ...
                       ' a string or a data type that can be cast to ' ...
                       'a string. The error message was: ' ...
                       classCastException.message]);
                runManager.execution.error_message = [runManager.execution.error_message ' ' classCastException.message];
            end
            
            % runManager.execution = Execution(tagStr);
            runManager.execution.tag = tagStr;
            
            % Set up yesWorkflow and pass the path of a script to yesWorkflow
            runManager.configYesWorkflow(filePath);
            
            % Begin recording
            runManager.startRecord(runManager.execution.tag);

            % End the recording session 
            runManager.endRecord();
     
        end
                
        function startRecord(runManager, tag)
            % STARTRECORD Starts recording provenance relationships (see record()).
                       
            if ( runManager.console == 1 ) % (Interactive mode) Dec-7-2015                              
                
                import org.dataone.client.run.Execution;
                
                % Set runManager.recording = true;
                runManager.recording = true;
                
                % Initialize a new execution object for this run
                runManager.execution = Execution();
                runManager.execution.execution_input_ids = {};
                runManager.execution.execution_output_ids = {};
                all_keys = keys(runManager.execution.execution_objects);
                remove(runManager.execution.execution_objects, all_keys);
                
                runManager.execution.tag = ''; % Todo: how to handle tag?
                
                % Use a uuid string as a temporary file name for the script
                % to be collected
                runManager.configuration.script_base_name = char(java.util.UUID.randomUUID());
            end
            
            % Record the starting time when record() started
            runManager.execution.start_time = datestr(now, 'yyyymmddTHHMMSS');
            
            if ( runManager.recording )
                warning(['A RunManager session is already active. Please call ' ...
                         'endRecord() if you wish to close this session']);
            end                
            
            % Open the provenance database connection 12-12-16
            runManager.provenanceDB.openDBConnection();
            
            % Compute script_base_name if it is not assigned a value
            if isempty( runManager.configuration.script_base_name )
                [pathstr,script_base_name,ext] = ...
                    fileparts(runManager.execution.software_application);
                runManager.configuration.script_base_name = ...
                    strtrim(script_base_name);    
            end
                  
            % Create an execution directory for the current run
            prov_dir = runManager.configuration.get('provenance_storage_directory');
            runManager.execution.execution_directory = ...
                fullfile(prov_dir, 'runs', runManager.execution.execution_id);
            [status, message, message_id] = ...
                mkdir(runManager.execution.execution_directory);
            if ( status ~= 1 )
                error(message_id, [ 'The directory %s' ...
                    ' could not be created. The error message' ...
                    ' was: ' runManager.execution.execution_directory, message]);
                runManager.execution.error_message = ...
                    [runManager.execution.error_message ' ' message];
            end
            
            % Set the correct value for execution.software_application
            if (runManager.console == 1) % (Interactive mode)    
                scriptName = [runManager.configuration.script_base_name '.m'];
                runManager.execution.software_application = fullfile( ...
                    runManager.execution.execution_directory, ...
                    scriptName);
            end
            
            warning off MATLAB:dispatcher:nameConflict;
            addpath(runManager.execution.execution_directory);
            warning on MATLAB:dispatcher:nameConflict;
            
            % Save current execmeta to the execmeta table and the tag table 12-13-16
            runManager.saveExecution(runManager.console);
                       
            % Add a DataObject to the execution objects map for the script
            % itself
            if (runManager.console ~= 1) % (Non-interactive mode)                 
                % Run the script and collect provenance information
                runManager.prov_capture_enabled = true;
                [pathstr, script_name, ext] = ...
                    fileparts(runManager.execution.software_application);
                               
                warning off MATLAB:dispatcher:nameConflict;
                addpath(pathstr);
                warning on MATLAB:dispatcher:nameConflict;
                
                try
                    % script_name
                    eval(script_name);
                catch runtimeError
                    set(runManager.execution, 'error_message', ...
                        [runtimeError.identifier ' : ' ...
                        runtimeError.message]);
                    disp(['The script: ' ...
                        runManager.execution.software_application ...
                        ' failed to run completely. See the error output.']);
                end
            end
        end
               
        function endRecord(runManager)
            % ENDRECORD Ends the recording of an execution (run).
            
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.client.v2.itk.DataPackage;           
            import java.io.File;
            import javax.activation.FileDataSource;
            import org.dataone.client.v1.types.D1TypeBuilder;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import java.net.URI;
            import org.dataone.util.ArrayListWrapper;
            import org.dataone.client.sqlite.FileMetadata;
            
            % Stop recording
            runManager.recording = false;
            runManager.prov_capture_enabled = false;
           
            % Get submitter and MN node reference
            submitter = runManager.execution.get('account_name');
            mnNodeId = runManager.configuration.get('target_member_node_id');
                     
            % Non-interactive mode
            if (runManager.console ~= 1)
                import org.dataone.client.v2.DataObject;
                               
                pid = ['program_' char(java.util.UUID.randomUUID())];
                dataObject = DataObject(pid, 'text/plain', ...
                    runManager.execution.software_application);
                
                % Call YesWorkflow to generate prospective provenance
                % graphs
                if runManager.configuration.capture_yesworkflow_comments
                    runManager.callYesWorkflow(runManager.execution.software_application, runManager.execution.execution_directory);
                end
            end
            
            % Record the ending time when record() ended using format 30 (ISO 8601)'yyyymmddTHHMMSS'
            runManager.execution.end_time = datestr(now, 'yyyymmddTHHMMSS');
            
            % Save the metadata for the current execution
            runManager.updateExecution(runManager.execution.execution_id);
            
            % Interactive mode
            if ( runManager.console == 1 )
                % Get the commands entered by the user
                
                import org.dataone.client.v2.DataObject;   
                
                % Access the command history using matlab java internal
                % classes
                history = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory; 
                startRecordIndex = 0;
                endRecordIndex = 0;
                for i= length(history): -1:1
                    % Try to find the position of the latest startRecord()
                    % and endRecord() pair from the command history
                    k = strfind(history(i), 'endRecord');
                    if ~isempty(k)
                        endRecordIndex = i-1; % last command is at position (i-1)
                    end
                    
                    k = strfind(history(i), 'startRecord');
                    if ~isempty(k)
                        startRecordIndex = i+1; % first command is at position (i+1)
                    end
                end
                
                % Write the commands history between startRecord() and
                % endRecord() to a file under the execution directory
                [fileId, message] = fopen(runManager.execution.software_application, 'wt');
                if fileId == -1, disp(message); end
                for i=startRecordIndex:endRecordIndex
                    fprintf(fileId, '%s\n', char(history(i)));
                end
                fclose(fileId);
                
                % Create a file for the collected commands and put the script
                % d1 object to the d1 datapackage (only for interactive mode) (Dec-7-2015)
                pid = char(java.util.UUID.randomUUID());
                dataObject = DataObject( pid, ...
                    'text/plain', ...
                    runManager.execution.software_application );
                runManager.execution.execution_objects(dataObject.identifier) = ...
                    dataObject;
            end
            
            % Archive the script that was executed. The script can be
            % retrived by searching for access="execute"
            [archiveRelDir, archivedRelFilePath, db_status] = FileMetadata.archiveFile(runManager.execution.software_application);
            if db_status == 1
                % The file has not been archived
                full_archive_file_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archivedRelFilePath);
                full_archive_dir_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archiveRelDir);
                if ~exist(full_archive_dir_path, 'dir')
                    mkdir(full_archive_dir_path);
                end
                % Copy this file to the archive directory
                copyfile(runManager.execution.software_application, full_archive_file_path, 'f');
            end
            
            program_metadata = FileMetadata(dataObject, runManager.execution.execution_id, 'execute');
            program_metadata.archivedFilePath = archivedRelFilePath;
            insert_program_query = program_metadata.writeFileMeta();
            status = runManager.provenanceDB.execute(insert_program_query, program_metadata.tableName);
            if status== -1
                message= 'DBError: insert a program metadata to the filemeta table.';
                error(message);
            end
                            
             % Build a D1 datapackage
            pkg = runManager.buildPackage( submitter, mnNodeId, runManager.execution.execution_directory );
            
            % Clear runtime input/output sources
            runManager.execution.execution_input_ids = {};
            runManager.execution.execution_output_ids = {};
           
            % Close the db on 12-12-16
            runManager.provenanceDB.closeDBConnection(); 
            
            % Set back to the default value of "console" (Dec-7-2015)
            % (non-interactive mode)
            if ( runManager.console ~= 1 )
                runManager.console = true; 
            end
                      
            % Unlock the RunManager instance
            munlock('RunManager');            
            % clear RunManager;
        end
                
        function runs = listRuns(runManager, varargin)
            % LISTRUNS Lists prior executions (runs) and information about them from executions metadata database.
            %   quiet -- control the output or not
            %   startDate -- the starting timestamp for an execution (yyyyMMddThh:mm:ss)
            %   endDate -- the ending timestamp for an execution  (yyyyMMddThh:mm:ss)
            %   tag -- a tag string given to an execution 
            %   runNumber -- a sequence number given to an execution
       
            persistent listRunsParser
            if isempty(listRunsParser)
                listRunsParser = inputParser;
               
                addParameter(listRunsParser,'quiet', false, @islogical);
                addParameter(listRunsParser,'startDate', '', @iscell);
                addParameter(listRunsParser,'endDate', '', @iscell);
                addParameter(listRunsParser,'tag', '', @(x) iscell(x) || ischar(x)); % accept both a single char array and a cell array
                checkSequenceNumber = @(x) (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(listRunsParser,'runNumber', '', checkSequenceNumber);
                addParameter(listRunsParser,'executionId', '', @ischar);
            end
            parse(listRunsParser,varargin{:})
            
            quiet = listRunsParser.Results.quiet;
            startDate = listRunsParser.Results.startDate;
            endDate = listRunsParser.Results.endDate;
            tags = listRunsParser.Results.tag;
            runNumber = listRunsParser.Results.runNumber;
            executionId = listRunsParser.Results.executionId;
            
            if runManager.configuration.debug
                listRunsParser.Results
            end
            
            % Open the provenance database connection 12-12-16
            runManager.provenanceDB.openDBConnection();
            
            % Create a SQL statement to retrieve all records satisfying the
            % selection criteria (072616)
            select_clause = ['SELECT em.seq, em.datapackageId, em.softwareApplication, em.startTime,' ...
                'em.endTime, em.publishTime, t.tag'];
            from_clause = sprintf('from %s em, %s t', 'execmeta', 'tags');
            where_clause = ['where em.executionId=t.executionId '];
           
            if isempty(startDate) ~= 1
                for i=1:length(startDate)
                    res = any(regexp(startDate{i}, '\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?')); % Sqlite only understand a small set of date formats. Todo: include other supported date formats. 072616
                    if res ~= 1
                        error('Input Date format is \d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?');
                    end
                end
                
                if length(startDate) == 1                    
                    start_begin_date = startDate{1};
                    start_end_date = '9999-99-99';
                elseif length(startDate) == 2
                    start_begin_date = startDate{1};
                    start_end_date = startDate{2};
                else
                    message = 'Error: the number of dates is more than 2.';
                    error(message);
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where em.startTime BETWEEN "%s" AND "%s" ', start_begin_date, start_end_date);
                else
                    where_clause = sprintf('%s and em.startTime BETWEEN "%s" AND "%s" ', where_clause, start_begin_date, start_end_date);
                end
            end
            
            if isempty(endDate) ~= 1
                for i=1:length(endDate)
                    res = any(regexp(endDate{i}, '\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?'));
                    if res ~= 1
                        error('Input Date format is \d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?');
                    end
                end
                
                if length(endDate) == 1                   
                    end_begin_date = endDate{1};
                    end_end_date = '9999-99-99';
                elseif length(startDate) == 2
                    end_begin_date = endDate{1};
                    end_end_date = endDate{2};
                else
                    message = 'Error: the number of dates is more than 2.';
                    error(message);
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where em.endTime BETWEEN "%s" AND "%s" ', end_begin_date, end_end_date);
                else
                    where_clause = sprintf('%s and em.endTime BETWEEN "%s" AND "%s" ', where_clause, end_begin_date, end_end_date);
                end
            end
                              
            if isempty(runNumber) ~= 1
                if isempty(where_clause)
                    where_clause = sprintf('where em.seq=%d', runNumber);
                else
                    where_clause = sprintf('%s and em.seq=%d', where_clause, runNumber);
                end              
            end
            
            if isempty(executionId) ~= 1 % suppport search based on primary key
                if isempty(where_clause)
                    where_clause = sprintf('where em.executionId="%s"', executionId);
                else
                    where_clause = sprintf('%s and em.executionId="%s"', where_clause, executionId);
                end
            end
              
            if isempty(tags) ~= 1
                if isempty(where_clause)
                    where_clause = sprintf('where t.tag="%s"', tags);
                else
                    where_clause = sprintf('%s and t.tag="%s"', where_clause, tags);
                end
            end
            
            % Create a SQL query joining the execmeta and tags tables
            select_query = sprintf('%s %s %s ;', select_clause, from_clause, where_clause);   
            exec_metadata_cell = runManager.provenanceDB.execute(select_query);
            
            % Display only when the returned data is a cell; no display for
            % 'No Data' returned
            if ~isempty(exec_metadata_cell)
                numOfRows = size(exec_metadata_cell, 1);
                for i=1:numOfRows
                    % Convert the full path of a script to a base file name in
                    % listRus(). The full path is displayed in viewRun()
                    fullName = exec_metadata_cell{i,3};
                    name_array = strsplit(fullName, filesep);
                    exec_metadata_cell{i,3} = char(name_array(end));
                    
                    % Covert startTime & endTime to readable format
                    start_time = exec_metadata_cell{i,4};
                    end_time = exec_metadata_cell{i,5};
                    start_formatted_time = datestr(datenum(start_time, 'yyyymmddTHHMMSS'));
                    end_formatted_time = datestr(datenum(end_time, 'yyyymmddTHHMMSS'));
                    exec_metadata_cell{i,4} = start_formatted_time;
                    exec_metadata_cell{i,5} = end_formatted_time;
                end
                
                % Display
                if isempty(quiet) ~= 1 && quiet ~= 1
                    % Convert a cell array to a table with headers
                    run_fieldnames = {'runNumber', 'packageId', 'scriptName', 'startDate', 'endDate', 'publishDate', 'tag'};
                    %  tableForSelectedRuns = cell2table(exec_metadata_cell,'VariableNames', {'runNumber', 'packageId', 'scriptName', 'startDate', 'endDate', 'publishDate', 'tag'});
                    %  disp(tableForSelectedRuns);
                    [nrows, ncols] = size(exec_metadata_cell);
                    for i=1:nrows
                        fprintf('Run #%3d: \n', i);
                        for j=1:ncols
                            if isnumeric(exec_metadata_cell{i,j})
                                fprintf('%16s: %d \n', run_fieldnames{j}, exec_metadata_cell{i,j});
                            else  
                                if ~isempty(exec_metadata_cell{i,j})
                                    fprintf('%16s: %s \n', run_fieldnames{j}, exec_metadata_cell{i,j});
                                else
                                    fprintf('%16s: %s \n', run_fieldnames{j}, 'N/A');
                                end
                            end
                        end
                        fprintf('\n');
                    end
                end
            else
                message = 'There is no data matched.';
                warning(message);
            end
            
            % Close the db on 12-12-16
            runManager.provenanceDB.closeDBConnection();
        end
        
        function deleted_runs = deleteRuns(runManager, varargin)
            % DELETERUNS Deletes prior executions (runs) from the stored
            % list.    
            %   executionIdList -- the list of runIds for executions to be deleted
            %   startDate -- the starting timestamp for an execution to be
            %                deleted  (yyyyMMddThh:mm:ss)
            %   endDate -- the ending timestamp for an execution to be
            %              deleted  (yyyyMMddThh:mm:ss)
            %   tag -- a list of tags given to an execution to be deleted
            %   runNumber -- a sequence number given to an execution to be deleted
            %   noop -- control delete the exuecution from disk or not
            %   quiet -- control the output or not
            
            import org.dataone.client.sqlite.FileMetadata;
             
            persistent deletedRunsParser
            if isempty(deletedRunsParser)
                deletedRunsParser = inputParser;
                
                addParameter(deletedRunsParser,'executionIdList', '', @iscell);
                addParameter(deletedRunsParser,'startDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(deletedRunsParser,'endDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(deletedRunsParser,'tagList', '', @iscell);
                checkSequenceNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(deletedRunsParser,'runNumber', '', checkSequenceNumber);
                addParameter(deletedRunsParser,'noop', false, @islogical);
                addParameter(deletedRunsParser,'quiet',false, @islogical);
            end
            parse(deletedRunsParser,varargin{:})
            
            executionIdList = deletedRunsParser.Results.executionIdList;
            startDate = deletedRunsParser.Results.startDate;
            endDate = deletedRunsParser.Results.endDate;
            tags = deletedRunsParser.Results.tagList;
            runNumber = deletedRunsParser.Results.runNumber;
            noop = deletedRunsParser.Results.noop;
            quiet = deletedRunsParser.Results.quiet;
            
            if runManager.configuration.debug
                deletedRunsParser.Results
            end
            
            % Open the provenance database connection 12-12-16
            runManager.provenanceDB.openDBConnection();
            
            % Create a SQL statement to retrieve all records satisfying the
            % selection criteria (110816)
            select_clause = ['SELECT em.*, t.tag'];
            from_clause = sprintf('from %s em, %s t', 'execmeta', 'tags');
            where_clause = ['where em.executionId=t.executionId '];
                        
            if isempty(startDate) ~= 1
                for i=1:length(startDate)
                    res = any(regexp(startDate{i}, '\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?')); % Sqlite only understand a small set of date formats. Todo: include other supported date formats. 072616
                    if res ~= 1
                        error('Input Date format is \d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?');
                    end
                end
                
                if length(startDate) == 1
                    start_begin_date = startDate{1};
                    start_end_date = '9999-99-99';
                elseif length(startDate) == 2
                    start_begin_date = startDate{1};
                    start_end_date = startDate{2};
                else
                    message = 'Error: the number of dates is more than 2.';
                    error(message);
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where em.startTime BETWEEN "%s" AND "%s" ', start_begin_date, start_end_date);
                else
                    where_clause = sprintf('%s and em.startTime BETWEEN "%s" AND "%s" ', where_clause, start_begin_date, start_end_date);
                end
            end
            
            if isempty(endDate) ~= 1
                for i=1:length(endDate)
                    res = any(regexp(endDate{i}, '\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?'));
                    if res ~= 1
                        error('Input Date format is \d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?');
                    end
                end
                
                if length(endDate) == 1
                    end_begin_date = endDate{1};
                    end_end_date = '9999-99-99';
                elseif length(startDate) == 2
                    end_begin_date = endDate{1};
                    end_end_date = endDate{2};
                else
                    message = 'Error: the number of dates is more than 2.';
                    error(message);
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where em.endTime BETWEEN "%s" AND "%s" ', end_begin_date, end_end_date);
                else
                    where_clause = sprintf('%s and em.endTime BETWEEN "%s" AND "%s" ', where_clause, end_begin_date, end_end_date);
                end
            end
            
            if ~isempty(executionIdList)
                execution_ids_str = sprintf('"%s"', executionIdList{1,1});
                for i=2:size(executionIdList,2)
                    temp = sprintf('"%s"', executionIdList{1,i});
                    execution_ids_str = strcat(execution_ids_str, ',', temp);                   
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where em.executionId in (%s)', execution_ids_str);
                else
                    where_clause = sprintf('%s and em.executionId in (%s)', where_clause, execution_ids_str);
                end
            end
                        
            if ~isempty(runNumber)             
                num_runNumber = num2str(runNumber);
                if isempty(where_clause)
                    where_clause = sprintf('where em.seq="%s"', num_runNumber);
                else
                    where_clause = sprintf('%s and em.seq="%s"', where_clause, num_runNumber);
                end
            end
            
            if ~isempty(tags)
                tags_str = sprintf('"%s"', tags{1,1});
                for i=2:size(tags,2)
                    temp = sprintf('"%s"', tags{1,i});
                    tags_str = strcat(tags_str, ',', temp);
                end
                
                if isempty(where_clause)
                    where_clause = sprintf('where t.tag in (%s)', tags_str);
                else
                    where_clause = sprintf('%s and t.tag in (%s)', where_clause, tags_str);
                end
            end
                       
             % Create a SQL query joining the execmeta and tags tables
            select_query = sprintf('%s %s %s ;', select_clause, from_clause, where_clause);   
            deleted_runs = runManager.provenanceDB.execute(select_query);
            
            % Delete the selected runs from the execution matrix and update the exeucution database
            if  noop == 1
                % Show the selected run list only when quiet is turned on
                if isempty(quiet) ~= 1 && quiet ~= 1
                    % Convert a cell array to a table with headers
                    disp('The following runs are matched and to be deleted:');
                    %                     tableForSelectedRuns = cell2table(deleted_runs,'VariableNames', [header{:}]);
                    %                     disp(tableForSelectedRuns);
                    
                    % Print all to runs to be deleted  110816
                    fieldnames = {'RunSequenceNumber', 'ExecutionId','MetadataId', 'DataPackageId', 'RunByUser', 'AccountSubject', ...
                        'HostId', 'RunStartTime', 'OperatingSystem', 'Runtime', 'SoftwareApplication', 'ModuleDependencies', ...
                        'RunEndingTime', 'ErrorMessageFromThisRun', 'PublishTime', 'PublishedNodeId', 'PublishedId', 'Console', 'Tag'};
                    
                    % Convert a cell array to a table with headers
                    % tableForDetailsSection = cell2table(exec_metadata_cell,'VariableNames', fieldnames);
                    % disp(tableForDetailsSection);
                    [nrows, ncols] = size(deleted_runs);
                    for i=1:nrows
                        fprintf('Run #%3d: \n', i);
                        for j=1:ncols                            
                            if length(deleted_runs{i,j}) >= 500
                                shorten_str = deleted_runs{i,j}(1:500);
                                fprintf('%30s:  %s \n', fieldnames{j}, shorten_str);
                            else
                                if ~isempty(deleted_runs{i,j})
                                    fprintf('%30s:  %s \n', fieldnames{j}, deleted_runs{i,j});
                                else
                                    fprintf('%30s: %s \n', fieldnames{j}, 'N/A');
                                end
                            end
                        end
                        fprintf('\n');
                    end
                end
            else
                % Show the selected run list and do the deletion operation
                selectedIdSet = deleted_runs(:,2);
                % Loop through selected runs
                for k = 1:length(selectedIdSet)
                    % Delete all file access entries for this execution, for
                    % any type of access, i.e., "read", "write", "execute". The
                    % file information for the deleted entries is returned.
                    % 110816                   
                    fm_all = FileMetadata('', selectedIdSet{k}, '','','','','','', '','','');
                    fm_query = fm_all.readFileMeta('', '');
                    file_stats_all = runManager.provenanceDB.execute(fm_query, fm_all.tableName);
                    
                    % Loop through the deleted file entries and unarchive
                    % any file associated with this run, i.e., file read,
                    % written, executed, etc. 110816
                    [nrows, ncols] = size(file_stats_all);
                    for i=1:nrows
                        this_file_id = file_stats_all{i,1};
                        % First delete the file in the archive, if no other
                        % executions are referring to it
                        [archivedRelFilePath, delete_archive_status] = FileMetadata.unArchiveFile(this_file_id);
                        if ~isempty(archivedRelFilePath) && delete_archive_status 
                           full_archive_file_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archivedRelFilePath);
                           delete(full_archive_file_path);
                        end
                        
                        % Then delete the filemeta table entry for it
                        delete_fm_query = sprintf('DELETE from filemeta WHERE fileId="%s" ', this_file_id);
                        result = runManager.provenanceDB.execute(delete_fm_query);
                    end
                    
                    % Delete the execmeta table and tags table entry
                    delete_em_query = sprintf('DELETE from execmeta WHERE executionId="%s" ', selectedIdSet{k});
                    delete_tag_query = sprintf('DELETE from tags WHERE executionId="%s" ', selectedIdSet{k});
                    result = runManager.provenanceDB.execute(delete_em_query);    
                    result = runManager.provenanceDB.execute(delete_tag_query); 
                    % Delete each run directory under provenance/runs/
                    % folder 
                    selectedRunDir = fullfile( ...
                        runManager.configuration.provenance_storage_directory, ...
                        'runs', selectedIdSet{k});
                    if exist(selectedRunDir, 'dir') == 7
                        [success, errMessage, messageID] = rmdir(selectedRunDir, 's');
                        if success == 1
                            fprintf('Succeed in deleting the run directory %s\n', selectedRunDir);
                        else
                            fprintf('Error in deleting a run directory %s and the error message is %s \n', ...
                                selectedRunDir, errMessage);
                        end
                    else
                        fprintf('The run %s directory to be deleted not exist.\n', selectedRunDir);
                    end
                    
                end               
            end 
            
            % Close the db on 12-12-16
            runManager.provenanceDB.closeDBConnection();
        end
        
        function results = viewRun(runManager, varargin)
           % VIEWRUN Displays detailed information about a data package that
           % is the result of an execution (run).
           %    import org.dataone.client.run.RunManager;
           %    mgr = RunManager.getInstance();
           %    mgr.viewRun('packageId', 'the-package-id') shows the run with the
           %        given package identifier
           %    mgr.viewRun('runNumber', 1) shows the run with the
           %        given run number
           %    mgr.viewRun('tag', 'the desired tag') shows the run with the
           %        given tag string
           %    mgr.viewRun('runNumber', 1, ...
           %         'sections', {'details', 'used', 'generated'}) shows 
           %        the run with the given run number and include the
           %        details, used, and generated sections

           % Note: Assume only one run report is to be viewed 11-11-16
           
           % Display a warning message to the user
           if runManager.configuration.debug
               disp('Warning: There is no scientific metadata in this data package.');
           end
           
           persistent viewRunsParser;
           if isempty(viewRunsParser)
               viewRunsParser = inputParser;
               
               addParameter(viewRunsParser,'packageId', '', @ischar);   
               addParameter(viewRunsParser, 'executionId', '', @(x) ~isempty(x)); % revised on 072816
               checkSequenceNumber = @(x) (isnumeric(x) && isscalar(x) && (x > 0));
               addParameter(viewRunsParser,'runNumber', '', checkSequenceNumber);
               addParameter(viewRunsParser,'tag', '', @(x) iscell(x) || ischar(x));
               addParameter(viewRunsParser,'sections', '', @iscell);
           end
           parse(viewRunsParser,varargin{:});
            
           packageId = viewRunsParser.Results.packageId;
           executionId = viewRunsParser.Results.executionId;
           runNumber = viewRunsParser.Results.runNumber;
           tags = viewRunsParser.Results.tag;
           sections = viewRunsParser.Results.sections;
            
           if runManager.configuration.debug
               viewRunsParser.Results
           end
            
           % Open the provenance database connection 12-12-16
           runManager.provenanceDB.openDBConnection();
            
           select_clause = ['SELECT em.seq, em.executionId, em.datapackageId, em.user, em.subject, ' ...
               'em.hostId, em.startTime, em.operatingSystem, em.runtime, em.softwareApplication, ' ...
               'em.endTime, em.errorMessage, em.publishNodeId, em.publishTime, t.tag '];
           from_clause = sprintf('from %s em, %s t', 'execmeta', 'tags');
           where_clause = ['where em.executionId=t.executionId '];
           
           if isempty(packageId) ~= 1
               if isempty(where_clause)
                   where_clause = sprintf('WHERE em.datapackageId="%s"', packageId);
               else
                   where_clause = sprintf('%s and em.datapackageId="%s"', where_clause, packageId);
               end              
           end
           
           if isempty(executionId) ~= 1
               if isempty(where_clause)
                   where_clause = sprintf('WHERE em.executionId="%s"', executionId);
               else
                   where_clause = sprintf('%s and em.executionId="%s"', where_clause, executionId);
               end               
           end
           
           if isempty(runNumber) ~= 1
               if isempty(where_clause)
                   where_clause = sprintf('WHERE em.seq=%d', runNumber);
               else
                   where_clause = sprintf('%s and em.seq=%d', where_clause, runNumber);
               end
           end
           
           if isempty(tags) ~= 1
               if isempty(where_clause)
                   where_clause = sprintf('WHERE t.tag="%s"', tags);
               else
                   where_clause = sprintf('%s and t.tag="%s"', where_clause, tags);
               end
           end
           
           select_query = sprintf('%s %s %s ;', select_clause, from_clause, where_clause);
           exec_metadata_cell = runManager.provenanceDB.execute(select_query);
           
           % Display only when the returned data is a cell
           if ~isempty(exec_metadata_cell)
               % Get the short script name and starting timestamp
               script_full_path = exec_metadata_cell{1,10};
               script_name_array = strsplit(script_full_path, filesep);
               scriptName = char(script_name_array(end));
              
               start_time = exec_metadata_cell{1,7};
               if ~isempty(start_time)
               start_formatted_time = datestr(datenum(start_time, 'yyyymmddTHHMMSS'));
               exec_metadata_cell{1,7} = start_formatted_time;
               else
                   exec_metadata_cell{1,7}='N/A';
               end
               
               end_time = exec_metadata_cell{1,11};
               if ~isempty(end_time)
               end_formatted_time = datestr(datenum(end_time, 'yyyymmddTHHMMSS'));
               exec_metadata_cell{1,12} = end_formatted_time;
               else
                   exec_metadata_cell{1,12}='N/A';
               end
               
               publish_time = exec_metadata_cell{1,14};
               if ~isempty(publish_time)
               publish_formatted_time = datestr(datenum(publish_time, 'yyyymmddTHHMMSS'));
               exec_metadata_cell{1,15} = publish_formatted_time;
               else
                   exec_metadata_cell{1,15}='N/A';
               end
               
               executionId = exec_metadata_cell{1,2};
           end
           
           % Decide the sections to be displayed based on values of sections
           if ~isempty(sections)
               sectionArray = char(sections);
               showDetails = ismember('details', sectionArray);
               showUsed = ismember('used', sectionArray);
               showGenerated = ismember('generated', sectionArray);
           else
               showDetails = 1;
               showUsed = 0;
               showGenerated = 0;
           end
           
           import org.dataone.client.sqlite.FileMetadata;
           
           used_file_stats = {};
           generated_file_stats = {};
           
           if showUsed == 1
               used_file_metadata = FileMetadata('', executionId, '','','','','','', 'read','',''); %103116
               used_file_query = used_file_metadata.readFileMeta('', '');
               used_file_stats = runManager.provenanceDB.execute(used_file_query, used_file_metadata.tableName);
           end
           
           if showGenerated == 1
               generated_file_metadata = FileMetadata('', executionId, '','','','','','', 'write','',''); %103116
               generated_file_query = generated_file_metadata.readFileMeta('', '');
               generated_file_stats = runManager.provenanceDB.execute(generated_file_query, generated_file_metadata.tableName);
           end
           
           results = {exec_metadata_cell, used_file_stats, generated_file_stats};
           
           more on; % Enable more for page control
           
           % Display different sections
           if showDetails == 1
               fprintf('\n[DETAILS]: Run details\n');
               fprintf('-------------------------\n');  
               fprintf('\"%s\" was executed on %s\n\n', scriptName, start_formatted_time);
              
               % Compute the detailStruct for the details_section
               fieldnames = {'RunSequenceNumber', 'ExecutionId','DataPackageId', 'RunByUser', 'AccountSubject', ...
                   'HostId', 'RunStartTime', 'OperatingSystem', 'Runtime', 'SoftwareApplication', ...
                   'RunEndingTime', 'ErrorMessageFromThisRun', 'PublishedNodeId', 'PublishedDate', 'Tag'};
               
               % Convert a cell array to a table with headers              
               % tableForDetailsSection = cell2table(exec_metadata_cell,'VariableNames', fieldnames);
               % disp(tableForDetailsSection);

               for i=1:length(fieldnames)
                   if length(exec_metadata_cell{1,i}) >= 500
                       shorten_str = exec_metadata_cell{1,i}(1:500);
                       fprintf('%20s:  %s \n', fieldnames{i}, shorten_str);
                   else
                       if ~isempty(exec_metadata_cell{1,i})
                           fprintf('%20s:  %s \n', fieldnames{i}, exec_metadata_cell{1,i});
                       else
                           fprintf('%20s: %s \n', fieldnames{i}, 'N/A');
                       end
                   end
               end
           end
           
           file_fieldnames = {'FilePath','Size','ModifiedTime'};
           if showUsed == 1
               fprintf('\n\n[USED]: %d Items used by this run\n', size(used_file_stats,1));
               fprintf('------------------------------------\n');
               if ~isempty(used_file_stats)
                   used_file_to_display = used_file_stats(:, [3,5,7]);
                   
                   %  TableForFileUsed = cell2table(used_file_to_display, 'VariableNames', {'FilePath','Size','ModifiedTime'}); % Convert a struct to a table
                   %  disp(TableForFileUsed);
                   
                   [nrows, ncols] = size(used_file_to_display);
                   for i=1:nrows
                       fprintf('File #%3d:\n', i);
                       for j=1:ncols
                           if isnumeric(used_file_to_display{i,j})
                               fprintf('%20s: %d (bytes)\n', file_fieldnames{j}, used_file_to_display{i,j});
                           else
                               fprintf('%20s: %s\n', file_fieldnames{j}, used_file_to_display{i,j});
                           end                           
                       end
                       fprintf('\n');
                   end
               else
                   warning('There is no matched data.');
               end
           end
           
           if showGenerated == 1
               fprintf('\n\n[GENERATED]: %d Items generated by this run\n', size(generated_file_stats,1));
               fprintf('------------------------------------------\n');
               if ~isempty(generated_file_stats)
                   generated_file_to_display = generated_file_stats(:, [3,5,7]);
                   %  TableForFileWasGeneratedBy = cell2table(generated_file_to_display, 'VariableNames', {'FilePath','Size','ModifiedTime'}); % Convert a struct to a table
                   %  disp(TableForFileWasGeneratedBy);
                   [nrows, ncols] = size(generated_file_to_display);
                   for i=1:nrows
                       fprintf('File #%3d:\n', i);
                       for j=1:ncols
                           if isnumeric(generated_file_to_display{i,j})
                               fprintf('%20s: %d (bytes)\n', file_fieldnames{j}, generated_file_to_display{i,j});
                           else
                               fprintf('%20s: %s\n', file_fieldnames{j}, generated_file_to_display{i,j});
                           end                          
                       end
                       fprintf('\n');
                   end
               else
                   warning('There is no matched data.');
               end
           end
           
           more off; % terminate more
              
           % Close the db on 12-12-16
           runManager.provenanceDB.closeDBConnection();
        end
        
        function package_id = publish(runManager, packageId)
            % PUBLISH Uploads a data package from a folder on disk
            % to the configured DataONE Member Node server.  This requires
            % that the Configuration.authentication_token and
            % Configuration.target_member_node_id properties are set.
            %
            %    import org.dataone.client.run.RunManager;
            %    mgr = RunManager.getInstance();
            %    pkg_id = mgr.publish(mgr, 'the-package-id')
            
            import java.lang.String;
            import java.lang.Boolean;
            import java.lang.Integer;
            import org.dataone.client.v2.MNode;
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.v2.itk.DataPackage;           
            import org.dataone.service.types.v2.SystemMetadata;
            import org.dataone.client.v2.Session;
            import org.dataone.service.util.TypeMarshaller;
            import org.dataone.service.types.v1.AccessPolicy;
            import org.dataone.service.types.v1.util.AccessUtil;
            import org.dataone.service.types.v1.Permission;            
            import org.dataone.service.types.v1.ReplicationPolicy;
            import org.dataone.service.types.v1.Subject;
            import org.dataone.configuration.Settings;
            
            prov_dir = runManager.configuration.get('provenance_storage_directory');
            curRunDir = fullfile(prov_dir, 'runs', packageId);
         
            if ( exist(curRunDir, 'dir') ~= 7 )
                error([' There was an error in publishing the run. ' ...
                    char(10) ...
                    'A directory was not found for the run identifier: ' ...
                    packageId]);               
            end                 
            
            % Get a MNode instance to the Member Node
            try                
                % Deserialize the execution object from the disk
                
                % Remove the path to the overloaded load() from the Matlab path
                overloadedFunctPath = which('load');
                [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
                rmpath(overloaded_func_path);
           
                % Load the stored execution given the directory name
                exec_file_base_name = [packageId '.mat'];
                stored_execution = load(fullfile( ...
                    runManager.configuration.provenance_storage_directory, ...
                    'runs', ...
                    packageId, ...
                    exec_file_base_name));
                
                % Add the path to the overloaded load() back to the Matlab path
                warning off MATLAB:dispatcher:nameConflict;
                addpath(overloaded_func_path, '-begin');
                warning on MATLAB:dispatcher:nameConflict;
                    
                % Assign deserialized execution to runManager.execution
                runManager.execution = stored_execution.executionObj(1);

                % Build a D1 datapackage
                if ( ~isempty(runManager.configuration.submitter) )
                    submitter = char(runManager.configuration.submitter);
                    
                else
                    submitter = char(runManager.execution.account_name); %Hack                  
                end
                
                if ( ~isempty(runManager.configuration.target_member_node_id) || ...
                        (strcmp(runManager.configuration.target_member_node_id, ...
                        'urn:node:XXXX')) )
                    mnNodeId = runManager.configuration.target_member_node_id;
                    
                else
                    error('RunManager:missingTargetMemberNode', ...
                        ['There is no valid Configuration.target_member_node_id set.\n', ...
                        'Please set it with the correct Member Node id.']);                 
                end
                
                % Build the package back into memory
                % pkg = runManager.buildPackage( ...
                %     submitter, mnNodeId, ...
                %     runManager.execution.execution_directory );    
                                
                % Get a Session
                session = Session();
                
                % Do we have a session object?
                if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                    msg = ['To publish a run to a Member Node, you need ' ...
                        'to be logged in. Please provide your credentials \n' ...
                        'either as a Configuration.authentication_token ' ...
                        'property, or a Configuration.certificate_path \n' ...
                        'property that points to an X509 certificate ' ...
                        'saved to disk.'];
                    error('RunManager:publish:missingCredentials', msg);
                    
                end
                
                % Without a valid session, throw an error
                if (  ~ session.isValid() )
                    
                    msg = ['Your session expired on ' ...
                        char(session.expiration_date) '.' ...
                        char(10) ...
                        ' Please renew your ' ...
                        session.type ...
                        char(10) ...
                        ' before calling the ''publish()'' function.'];
                    error('RunManager:publish:expiredCredentials',msg);
                    
                end
                                
                % Set the CN URL in the Java Client Library
                if ( ~isempty(runManager.configuration.coordinating_node_base_url) )
                    Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                        runManager.configuration.coordinating_node_base_url);
                end
                
                Settings.getConfiguration().setProperty('D1Client.default.timeout', 300000);
                
                % Set the CNode ID
                cnRef = NodeReference();
                cnRef.setValue(runManager.configuration.coordinating_node_base_url);
                cnNode = D1Client.getCN(cnRef.getValue());
                if isempty(cnNode)
                    error(['Coordinatior node' runManager.D1_CN_Resolve_Endpoint ...
                        'encounted an error on the getCN() request.']);
                end
                
                                
                % Set the MNode ID
                mnRef = NodeReference();
                mnRef.setValue(runManager.configuration.target_member_node_id);
                % Get a MNode instance to the Member Node using the Node ID
                mnNode = D1Client.getMN(mnRef);
                if isempty(mnNode)
                    error(['Member node' ...
                        runManager.configuration.target_member_node_id ...
                        'encounted an error on the getMN() request.']);
                end
                
                mn_base_url = char(mnNode.getNodeBaseServiceUrl());
                targetMNodeStr = runManager.configuration.get('target_member_node_id');
                
                submitter = Subject();
                submitter.setValue(session.account_subject);
                
                % Upload each data object in the execution_objects map
                identifiers = keys(runManager.execution.execution_objects);
                d1objects = values(runManager.execution.execution_objects);
                
                for k = 1: length(identifiers)
                    
                    d1_object_id = identifiers{k};
                    d1_object = d1objects{k};
                    d1_object_format = char(d1_object.format_id);
                    
                    if true % runManager.configuration.debug
                        fprintf( ...
                            ['Uploading to : %s\n' ...
                             'File format  : %s\n' ...
                             'File path    : %s\n'], ...
                            [mn_base_url '/object/' d1_object_id], ...
                            d1_object_format, ...
                            d1_object.full_file_path);
                    end
                                          
                    % build d1 object
                    dataObj = runManager.buildD1Object(d1_object.full_file_path, ...
                        d1_object_format, d1_object_id, submitter.getValue(), targetMNodeStr);
                    dataSource = dataObj.getDataSource();
                    
                    % get system metadata for dataObj 
                    v2SysMeta = dataObj.getSystemMetadata(); % version 2 system metadata
                    
                    if runManager.configuration.debug
                        fprintf('***********************************************************\n');
                        fprintf('d1Obj.size=%d (bytes)\n', v2SysMeta.getSize().longValue());                   
                        fprintf('d1Obj.checkSum algorithm is %s and the value is %s\n', char(v2SysMeta.getChecksum().getAlgorithm()), char(v2SysMeta.getChecksum().getValue()));
                        fprintf('d1Obj.rightsHolder=%s\n', char(v2SysMeta.getRightsHolder().getValue()));
                        fprintf('d1Obj.sysMetaModifiedDate=%s\n', char(v2SysMeta.getDateSysMetadataModified().toString()));
                        fprintf('d1Obj.dateUploaded=%s\n', char(v2SysMeta.getDateUploaded().toString()));
                        fprintf('d1Obj.originalMNode=%s\n', char(v2SysMeta.getOriginMemberNode().getValue()));
                        fprintf('***********************************************************\n');
                    end
                    
                    % set the other information for sysmeta (submitter, rightsHolder, foaf_name, AccessPolicy, ReplicationPolicy)                                    
                    v2SysMeta.setFileName(d1_object.system_metadata.getFileName());
                    v2SysMeta.setSubmitter(submitter);
                    v2SysMeta.setRightsHolder(submitter);
                    
                    if runManager.configuration.public_read_allowed == 1
                        strArray = javaArray('java.lang.String', 1);
                        permsArray = javaArray('org.dataone.service.types.v1.Permission', 1);
                        strArray(1,1) = String('public');
                        permsArray(1,1) = Permission.READ;
                        ap = AccessUtil.createSingleRuleAccessPolicy(strArray, permsArray);
                        v2SysMeta.setAccessPolicy(ap);
                        if runManager.configuration.debug
                            fprintf('d1Obj.accessPolicySize=%d\n', v2SysMeta.getAccessPolicy().sizeAllowList());
                        end
                    end                   
                                    
                    if runManager.configuration.replication_allowed == 1
                        rp = ReplicationPolicy();
                        numReplicasStr = String.valueOf(int32(runManager.configuration.number_of_replicas));
                        rp.setNumberReplicas(Integer(numReplicasStr));                       
                        rp.setReplicationAllowed(java.lang.Boolean.TRUE);                      
                        v2SysMeta.setReplicationPolicy(rp);               
                        if runManager.configuration.debug
                            fprintf('d1Obj.numReplicas=%d\n', v2SysMeta.getReplicationPolicy().getNumberReplicas().intValue());  
                        end
                    end
                    
                    % Upload the data to the MN using create(), 
                    % checking for success and a returned identifier       
                    pid = v2SysMeta.getIdentifier();
                    j_session = session.getJavaSession();
                    
                    try
                        % Check if the identifier has been used. If so,
                        % skip uploading the current file object
                        returnPid = cnNode.reserveIdentifier(j_session, pid);
                        
                        returnPid = mnNode.create(j_session, pid, dataSource.getInputStream(), v2SysMeta);
                        if isempty(returnPid) ~= 1
                            fprintf('Success      : Uploaded %s\n\n', char(v2SysMeta.getFileName()));
                            
                        else
                            % TODO: Process the error correctly.
                            error('Error on returned identifier %s', char(v2SysMeta.getIdentifier()));                            
                        end
                    catch
                        msg = ['Error on duplicate identifier' char(v2SysMeta.getIdentifier().getValue())];
                        warning(msg);
                        
                        continue; % Ignore the duplicate error and upload the next file object
                    end
                end
                
                package_id = packageId; 
         
            catch runtimeError 
                runManager.execution.error_message = ...
                    [runManager.execution.error_message ' ' ...
                    runtimeError.message];
                error(['There was an error trying to publish the run: ' ...
                    char(10) ...
                    runtimeError.message]);
                
            end
            
            % Record the date and time that the package from this run is uploaded to DataONE
            publishedTime = datestr( now,'yyyymmddTHHMMSS' );

            [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
            numOfRows = size(execMetaMatrix, 1);
            for i=1:numOfRows
                if strcmp(execMetaMatrix{i,6}, packageId)
                    execMetaMatrix{i,5} = publishedTime;
                end
            end
            
            % Write the updated execution metadata with headers to the execution
            % T = cell2table(execMetaMatrix, 'VariableNames', [header{:}]);
            % writetable(T, runManager.configuration.execution_db_name);
            % Write the updated execution metadata with headers to the execution database
            formatSpec = runManager.configuration.execution_db_write_format;
            if exist(runManager.configuration.execution_db_name, 'file') == 2
                [fileId, message] = ...
                    fopen(runManager.configuration.execution_db_name,'w');
                if fileId == -1
                    disp(message);
                end
                fprintf(fileId, formatSpec, ...
                    'runId', ...
                    'filePath', ...
                    'startTime', ...
                    'endTime', ...
                    'publishedTime', ...
                    'packageId', ...
                    'tag', ...
                    'user', ...
                    'subject', ...
                    'hostId', ...
                    'operatingSystem', ...
                    'runtime', ...
                    'moduleDependencies', ...
                    'console', ...
                    'errorMessage', ...
                    'runNumber');
                [rows, cols] = size(execMetaMatrix);
                for (row = 1:rows)
                    fprintf(fileId, formatSpec, ...
                        char(execMetaMatrix(row, 1)), ...
                        char(execMetaMatrix(row, 2)), ...
                        char(execMetaMatrix(row, 3)), ...
                        char(execMetaMatrix(row, 4)), ...
                        char(execMetaMatrix(row, 5)), ...
                        char(execMetaMatrix(row, 6)), ...
                        char(execMetaMatrix(row, 7)), ...
                        char(execMetaMatrix(row, 8)), ...
                        char(execMetaMatrix(row, 9)), ...
                        char(execMetaMatrix(row, 10)), ...
                        char(execMetaMatrix(row, 11)), ...
                        char(execMetaMatrix(row, 12)), ...
                        char(execMetaMatrix(row, 13)), ...
                        char(execMetaMatrix(row, 14)), ...
                        char(execMetaMatrix(row, 15)), ...
                        char(execMetaMatrix(row, 16)));
                end
                fclose(fileId);
            end
        end
        
        function combFileName = getYWCombViewFileName(runManager)
            combFileName = runManager.combinedViewPdfFileName;
        end
        
        function science_metadata = getMetadata(runManager, varargin)
            % GETMETADATA retrieves the metadata describing data objects of
            % a execution. when a script or console session is recorded, a
            % metadata object is created that describes the objets
            % associated with the run, using the Ecological Metadata
            % Language
            %   packageId -- The package identifier for a run
            %   runNumber -- The run number for a run 
            
            persistent getMetadataParser
            if isempty(getMetadataParser)
                getMetadataParser = inputParser;
                addParameter(getMetadataParser,'packageId', '', @ischar);
                checkRunNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(getMetadataParser,'runNumber', '', checkRunNumber);
            end
            
            parse(getMetadataParser, varargin{:})
            
            runId = getMetadataParser.Results.packageId;
            runNumber = getMetadataParser.Results.runNumber;
            
            if runManager.configuration.debug
                getMetadataParser.Results
            end
            
            if ~isempty(runNumber)
                snValue = num2str(runNumber);
                % Read the exeuction metadata summary from the exeuction metadata database
                [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
                
                % Initialize the logical cell arrays for the next call for listRuns()
                runNumberCondition = false(size(execMetaMatrix, 1), 1);
                
                % Extract one row from a matrix satisfying the runNumberCondition
                runNumberCondition = strcmp(execMetaMatrix(:,16), snValue);
                selectedRun = execMetaMatrix(runNumberCondition, :);
                if isempty(selectedRun)
                    error('No runs can be found as a match.');
                end
                runId = selectedRun{1, 6};
            end
            
            run_directory = fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', runId);
            
            % Check if the file exists
            if ( exist(run_directory, 'dir') == 7)
                
                science_metadata_file = ['metadata_' runId '.xml'];
                if ( exist(fullfile( run_directory, ...
                        science_metadata_file), 'file') )
                    import org.ecoinformatics.eml.EML;
                    eml = EML.loadDocument( ...
                        fullfile(run_directory, ...
                        science_metadata_file));
                  
                    science_metadata = eml.toXML;
                end
            else
                disp(['There is no run directory with the id: ' runId]);
                return;               
            end            
        end
        
        function putMetadata(runManager, varargin)
            % PUTMETADATA puts a metadata document into the recordr cache
            % for a run, replacing the existing metadata object for the
            % specified run, if one exits.
            %   file -- The replacement metadata as a file name
            %           containing the metadata           
            %   packageId -- The identifier for a run
            %   runNumber -- The run number for a run
           
            persistent putMetadataParser
            if isempty(putMetadataParser)
                putMetadataParser = inputParser;              
                addParameter(putMetadataParser,'packageId', '', @ischar);
                checkRunNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(putMetadataParser,'runNumber', '', checkRunNumber);  
                addParameter(putMetadataParser,'file','', @(x)any(~isempty(x)));
            end
            
            parse(putMetadataParser, varargin{:})
            
            runId = putMetadataParser.Results.packageId;
            runNumber = putMetadataParser.Results.runNumber;
            file = putMetadataParser.Results.file;
            
            if runManager.configuration.debug
                putMetadataParser.Results
            end
           
            if ~isempty(runNumber)
                snValue = num2str(runNumber);
                % Read the exeuction metadata summary from the exeuction metadata database
                [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
                
                % Initialize the logical cell arrays for the next call for listRuns()
                runNumberCondition = false(size(execMetaMatrix, 1), 1);
                
                % Extract one row from a matrix satisfying the runNumberCondition
                runNumberCondition = strcmp(execMetaMatrix(:,16), snValue);                
                selectedRun = execMetaMatrix(runNumberCondition, :);
                if isempty(selectedRun)
                    error('No runs can be found as a match.');
                end
                runId = selectedRun{1, 6};
            end
            
            run_directory = fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', runId);
            
            if ischar(file)
                % file is a filename containing the metadata
                if ( ~ exist(file, 'file') )
                    error('RunManager:putMetadata:IOError', ...
                        ['The file ' file 'does not exist.']);
                end
                
                % Check if the file exists
                if ( exist(run_directory, 'dir') == 7)
                    science_metadata_file = ['metadata_' runId '.xml'];
                    
                    % TODO: validate the metadata
                    
                    [status, message] = copyfile( ...
                        file, ...
                        fullfile(run_directory, science_metadata_file), 'f');
                    if ( status ~= 1 )
                        error('RunManager:putMetadata:IOError', ...
                            message);
                    end
                else
                    disp(['There is no run directory with the id: ' runId]);
                    return;
                end
           
            end
        end
        
        function buildFacts(runManager, outputFilePath, varargin)
            
            import org.dataone.client.sqlite.FileMetadata;
            import org.dataone.client.sqlite.ExecMetadata;
            import org.dataone.client.query.FactsExportBuilder;
            
            if isempty(varargin)
                query_engine = runManager.DEFAULT_QUERY_ENGINE;
            else
                query_engine = varargin{1};
            end
                         
           % Open the provenance database connection 12-12-16
           runManager.provenanceDB.openDBConnection();
           
            % Create a SQL query to export all data in the execmeta table
            em_query = 'select * from execmeta';
            em_data_cell = runManager.provenanceDB.execute(em_query);
            
            % Create a SQL query to export all data in the filemeta table
            fm_query = 'select * from filemeta';
            fm_data_cell = runManager.provenanceDB.execute(fm_query);
            
            % Create a SQL query to export all data in the tags table
            tag_query = 'select * from tags';
            tag_data_cell = runManager.provenanceDB.execute(tag_query);
                       
            execmetaFacts = FactsExportBuilder(query_engine, 'execmeta', 'Seq', 'ExecutionId', 'MetadataId', ...
                'DatapackageId', 'User', 'Subject', 'HostId', 'StartTime', ...
                'OperatingSystem', 'Runtime', 'SoftwareApplication', ...
                'EndTime', 'ErrorMessage', 'PublishTime', 'PublishNodeId', 'PublishId', 'Console');
            
            filemetaFacts= FactsExportBuilder(query_engine, 'filemeta', 'FileId', 'ExecutionId', 'FilePath', ...
                'Sha256', 'Size', 'User', 'ModifyTime', 'CreateTime', 'Access', 'Format', 'ArchivedFilePath');
            
            tagFacts = FactsExportBuilder(query_engine, 'tag', 'Seq', 'ExecutionId', 'Tag');
            
            [em_nrows, ~] = size(em_data_cell);
            for i=1:em_nrows
                execmetaFacts.addRow(em_data_cell{i,:});
            end
            
            [fm_nrows, ~] = size(fm_data_cell);
            for j=1:fm_nrows
                filemetaFacts.addRow(fm_data_cell{j,:});
            end
            
            [tag_nrows, ~] = size(tag_data_cell);
            for k=1:tag_nrows
                tagFacts.addRow(tag_data_cell{k,:});
            end
            
            % outputFilePath = '/Users/syc/Documents/idaks/runManager-multipleRuns/factsdump';
            tagFacts.writeFacts(outputFilePath, 'tagfacts.P');
            filemetaFacts.writeFacts(outputFilePath, 'filemetafacts.P');
            execmetaFacts.writeFacts(outputFilePath, 'execmetafacts.P');
            
            % Close the db on 12-12-16
            runManager.provenanceDB.closeDBConnection();
        end
    end

end
