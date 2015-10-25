% RUNMANAGER A class used to track information about program runs.
%   The RunManager class provides functions to manage script runs in terms
%   of the known file inputs and the derived file outputs. It keeps track
%   of the provenance (history) relationships between these inputs and outputs.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2015 DataONE
%
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
        mfilename = '';
        efilename = '';
        
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
    end
   
    methods (Access = private)

        function manager = RunManager(configuration)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            % The RunManager class manages outputs of a script based on the
            % settings in the given configuration passed in.
            import org.dataone.client.configure.Configuration;
            
            warning('off','backtrace');
            manager.configuration = configuration;
            configuration.saveConfig();            
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
                standardizedName = CertificateManager.getInstance().standardizeDN(dn);
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
            
            runManager.extractor = DefaultExtractor;
            runManager.modeler = DefaultModeler;
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
                    
                    % Set the working directory to be the run metadata directory for this run
                    curDir = pwd();
                    cd(runDirectory);
                    
                    runManager.grapher = runManager.grapher.workflow(runManager.workflow);

                    % Generate YW.Process_View dot file  
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.process_view_property_file_name); % Read from process_view_yw.properties
                    gconfig = config.getSection('graph');
                    runManager.processViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();           
                                                         
                    % Generate YW.Data_View dot file                  
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.data_view_property_file_name); % Read from data_view_yw.properties 
                    gconfig = config.getSection('graph');
                    runManager.dataViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();
                   
                    % Generate YW.Combined_View dot file                   
                    config.applyPropertyFile(runManager.configuration.yesworkflow_config.combined_view_property_file_name); % Read from comb_view_yw.properties
                    gconfig = config.getSection('graph');
                    runManager.combinedViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();
                   
                    % Create yesWorkflow modelFacts prolog dump 
                    import org.yesworkflow.model.ModelFacts;
                    import org.yesworkflow.extract.ExtractFacts;
                    
                    import org.dataone.client.v2.D1Object;
                    
                    prologDumpFormatId = 'text/plain';
                    
                    modelFacts = runManager.modeler.getFacts();  
                    gconfig = config.getSection('model');
                    runManager.mfilename = gconfig.get('factsfile');
                    mf_fullFilePath = [runDirectory filesep runManager.mfilename];
                    fw = fopen(mf_fullFilePath, 'w'); 
                    if fw == -1, error('Cannot write "%s%".',runManager.mfilename); end
                    fprintf(fw, '%s', char(modelFacts));
                    fclose(fw);
                    
                    % Create D1 object for yesworkflow model facts dump file and put
                    % its id into execution_output_ids array
                    mf_pid = char(java.util.UUID.randomUUID());
                    mf_d1Object = D1Object(mf_pid, prologDumpFormatId, mf_fullFilePath); 
                    runManager.execution.execution_objects(mf_d1Object.identifier) = ...
                        mf_d1Object;
                    runManager.execution.execution_output_ids{end+1} = mf_pid;
                    
                    % Create yesWorkflow extractFacts prolog dump
                    extractFacts = runManager.extractor.getFacts(); 
                    gconfig = config.getSection('extract');
                    runManager.efilename = gconfig.get('factsfile');
                    ef_fullFilePath = [runDirectory filesep runManager.efilename];
                    fw = fopen(ef_fullFilePath, 'w');    
                    if fw == -1, error('Cannot write "%s%".',runManager.efilename); end
                    fprintf(fw, '%s', char(extractFacts));
                    fclose(fw);
                   
                    % Create D1 object for yesworkflow extract facts dump file and put
                    % its id into execution_output_ids array
                    ef_pid = char(java.util.UUID.randomUUID());
                    ef_d1Object = D1Object(ef_pid, prologDumpFormatId, ef_fullFilePath);
                    runManager.execution.execution_objects(ef_d1Object.identifier) = ...
                        ef_d1Object;
                    runManager.execution.execution_output_ids{end+1} = ef_pid;
                    
                    cd(curDir); % go back to current working directory          
                end  
                
            catch ME 
                error(ME.message);
            end      
        end
 
       
        function generateYesWorkflowGraphic(runManager, runDirectory)
            % GENERATEYESWORKFLOWGRAPHIC Generates yesWorkflow graphcis in pdf format    
            
            import org.dataone.client.v2.D1Object;
            
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
                system(['/usr/local/bin/dot -Tpdf '  fullPathProcessViewDotFileName ' -o ' fullPathProcessViewPdfFileName]);
                system(['/usr/local/bin/dot -Tpdf '  fullPathDataViewDotFileName ' -o ' fullPathDataViewPdfFileName]);  
                system(['/usr/local/bin/dot -Tpdf '  fullPathCombViewDotName ' -o ' fullPathCombinedViewPdfFileName]); % for linux & mac platform, not for windows OS family             
            
                delete(fullPathProcessViewDotFileName);
                delete(fullPathDataViewDotFileName);
                delete(fullPathCombViewDotName);
                
                % Create D1 object for three yesworkflow images and put
                % them into execution_output_ids array
                comb_image_pid = char(java.util.UUID.randomUUID());
                comb_image_d1Object = D1Object(comb_image_pid, imageFormatId, fullPathCombinedViewPdfFileName);
                runManager.execution.execution_objects(comb_image_d1Object.identifier) = ...
                        comb_image_d1Object;
                runManager.execution.execution_output_ids{end+1} = comb_image_pid;
                
                process_image_pid = char(java.util.UUID.randomUUID());
                process_image_d1Object = D1Object(process_image_pid, imageFormatId, fullPathProcessViewPdfFileName);
                runManager.execution.execution_objects(process_image_d1Object.identifier) = ...
                        process_image_d1Object;
                runManager.execution.execution_output_ids{end+1} = process_image_pid;
                
                data_image_pid = char(java.util.UUID.randomUUID());
                data_image_d1Object = D1Object(data_image_pid, imageFormatId, fullPathDataViewPdfFileName);
                runManager.execution.execution_objects(data_image_d1Object.identifier) = ...
                        data_image_d1Object;
                runManager.execution.execution_output_ids{end+1} = data_image_pid;
            end
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
        
       
        function data_package = buildPackage2(runManager, submitter, mnNodeId, dirPath)
            import org.dataone.client.v2.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;            
            import org.dataone.client.run.NamedConstant;
            import org.dataone.util.ArrayListWrapper;
            import org.dataone.client.v2.itk.D1Object;
            import com.hp.hpl.jena.vocabulary.RDF;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import org.dataone.vocabulary.ProvONE_V1;
            import java.net.URI;
            import org.dspace.foresite.ResourceMap;
            import org.dataone.vocabulary.DC_TERMS;
            
            import org.dataone.client.v2.D1Object;
                       
            if runManager.configuration.debug
                disp('====== buildPackage ======');
            end
           
            % Get the run identifier from the directory name
            path_array = strsplit(dirPath, filesep);
            identifier = char(path_array(end));
            
            % Load the stroed execution given the directory name
            exec_file_base_name = [identifier '.mat'];
            stored_execution = load(fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', ...
                identifier, ...
                exec_file_base_name));

            % Assign deserialized execution to runManager.execution
            runManager.execution = stored_execution.executionObj(1);
            
            % Initialize a dataPackage to manage the run
            scriptIdentifier = runManager.execution.getIdByFullFilePath( ...
                runManager.execution.software_application);
                      
            packageIdentifier = Identifier();
            packageIdentifier.setValue(runManager.execution.execution_id);      
           
            % Create a resourceMap identifier
            resourceMapId = Identifier();
            resourceMapId.setValue(['resourceMap_' runManager.execution.execution_id]);
            % Create an empty datapackage with resourceMapId
            runManager.dataPackage = DataPackage(resourceMapId);
            
            % Get the base URL of the DataONE coordinating node server
            runManager.D1_CN_Resolve_Endpoint = ...
                [char(runManager.configuration.coordinating_node_base_url) '/v1/resolve/'];
            
            runManager.provONEdataURI = URI(ProvONE.Data.getURI());
            runManager.aTypePredicate = runManager.asPredicate(RDF.type, 'rdf');
            provOneProgramURI = URI(ProvONE.Program.getURI());            
            
            hadPlanPredicate = PROV.predicate('hadPlan');
            provAssociationURI = URI(PROV.Association.getURI());
            qualifiedAssociationPredicate = PROV.predicate('qualifiedAssociation');
            provOneExecURI = URI(ProvONE.Execution.getURI()); 
            wasAssociatedWithPredicate = PROV.predicate('wasAssociatedWith');
            agentPredicate = PROV.predicate('agent');
            provONEUserURI = URI(ProvONE.User.getURI());                                                
            runManager.execution.execution_uri = ...
                URI([runManager.D1_CN_Resolve_Endpoint  ...
                'execution_' runManager.execution.execution_id]);
            runManager.associationSubjectURI = ...
                URI([runManager.D1_CN_Resolve_Endpoint ...
                'a_' char(java.util.UUID.randomUUID())]);
            usedPredicate = PROV.predicate('used');
            
            % Create a D1Object for the program that we are running and
            %    update the resulting sysmeta in the stored exucution matlab D1Object
            scriptD1Obj = runManager.execution.execution_objects(scriptIdentifier);
            programD1JavaObj = runManager.buildD1Object( ...
                scriptD1Obj.full_file_path, scriptD1Obj.format_id, ...
                scriptD1Obj.identifier, submitter, mnNodeId);
            runManager.dataPackage.addData(programD1JavaObj);
            set(scriptD1Obj, 'system_metadata', programD1JavaObj.getSystemMetadata);
            runManager.execution.execution_objects(scriptIdentifier) = scriptD1Obj;
            
            % Create a D1 identifier for the workflow script  
            runManager.wfIdentifier = Identifier();                   
            runManager.wfIdentifier.setValue(scriptD1Obj.identifier);
          
            % Record relationship identifying workflow identifier and URI as a provONE:Program
            runManager.dataPackage.insertRelationship( ...
                runManager.wfIdentifier.getValue(), ...
                runManager.aTypePredicate, ...
                provOneProgramURI);
            
            % Describe the workflow identifier with resovlable URI 
            wfSubjectURI = URI([runManager.D1_CN_Resolve_Endpoint ...
                char(runManager.wfIdentifier.getValue())]);
            runManager.dataPackage.insertRelationship( ...
                wfSubjectURI, ...
                runManager.aTypePredicate, ...
                provOneProgramURI);
           
            % Store the prov relationship: association->prov:hadPlan->program
            runManager.dataPackage.insertRelationship( ...
                runManager.associationSubjectURI, ...
                hadPlanPredicate, ...
                provOneProgramURI);
            
            % Record relationship identifying association id as a prov:Association
            runManager.dataPackage.insertRelationship( ...
                runManager.associationSubjectURI, ...
                runManager.aTypePredicate, ...
                provAssociationURI);
                        
            % Store the prov relationship: execution->prov:qualifiedAssociation->association
            runManager.dataPackage.insertRelationship( ...
                runManager.execution.execution_uri, ...
                qualifiedAssociationPredicate, ...
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
       
            % Process execution_output_ids
            for i=1:length(runManager.execution.execution_output_ids)
                outputId = runManager.execution.execution_output_ids{i};
                
                outputD1Obj = runManager.execution.execution_objects(outputId);
                
                submitter = runManager.execution.account_name;
                mnNodeId = runManager.configuration.target_member_node_id;
                
                if runManager.configuration.debug
                    outputD1Obj.full_file_path
                end
                
                outputD1JavaObj = runManager.buildD1Object( ...
                        outputD1Obj.full_file_path, outputD1Obj.format_id, ...
                        outputD1Obj.identifier, submitter, mnNodeId);
                    
                runManager.dataPackage.addData(outputD1JavaObj);
                systemMetadata = outputD1JavaObj.getSystemMetadata; % java version sysmeta            
                systemMetadata.setFileName(outputD1Obj.system_metadata.getFileName); % use Java sysmeta base file name to set matlab sysmeta
                
                set(outputD1Obj, 'system_metadata', outputD1JavaObj.getSystemMetadata);
                
                runManager.execution.execution_objects(outputD1Obj.identifier) = outputD1Obj;
                
                outSourceURI = URI([runManager.D1_CN_Resolve_Endpoint outputD1Obj.identifier]); 
                runManager.dataPackage.insertRelationship( ...
                    outSourceURI, ...
                    wasAssociatedWithPredicate, ...
                    runManager.execution.execution_uri );
                
                runManager.dataPackage.insertRelationship(...
                    outSourceURI, ...
                    runManager.aTypePredicate, ...
                    runManager.provONEdataURI);
            end
            
            % Process execution_input_ids
            for i=1:length(runManager.execution.execution_input_ids)
                inputId = runManager.execution.execution_input_ids{i};
       
                startIndex = regexp( inputId,'http' ); 
                if isempty(startIndex)                   
                    inputD1Obj = runManager.execution.execution_objects(inputId);
  
                    submitter = runManager.execution.account_name;
                    mnNodeId = runManager.configuration.target_member_node_id;
                    
                    inputD1JavaObj = runManager.buildD1Object( ...
                        inputD1Obj.full_file_path, inputD1Obj.format_id, ...
                        inputD1Obj.identifier, submitter, mnNodeId);
                
                    runManager.dataPackage.addData(inputD1JavaObj);
                    systemMetadata = inputD1JavaObj.getSystemMetadata; % java version sysmeta            
                    systemMetadata.setFileName(inputD1Obj.system_metadata.getFileName); % use Java sysmeta base file name to set matlab sysmeta
                
                    set(inputD1Obj, 'system_metadata', inputD1JavaObj.getSystemMetadata);
                
                    runManager.execution.execution_objects(inputD1Obj.identifier) = inputD1Obj;
                
                    inSourceURI = URI([runManager.D1_CN_Resolve_Endpoint inputD1Obj.identifier]); 
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
            
            % Serialize a datapackage
            rdfXml = runManager.dataPackage.serializePackage();
         
            % Write to a resourceMap file
            resourceMapName = [char(resourceMapId.getValue()) '.rdf'];  
            resourceMapFullPath = fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', ...
                identifier, ...
                resourceMapName);
            fw = fopen(resourceMapFullPath, 'w'); 
            if fw == -1, error('Cannot write "%s%".',resourceMapFullPath); end
            fprintf(fw, '%s', char(rdfXml));
            fclose(fw);

            % Add resourceMap D1Object to the DataPackage                      
            resMapFmt = 'http://www.openarchives.org/ore/terms'; 
            resMapD1JavaObj = runManager.buildD1Object(resourceMapFullPath, resMapFmt, resourceMapName, submitter, mnNodeId);
            runManager.dataPackage.addData(resMapD1JavaObj);     
           
            data_package = runManager.dataPackage;
            
        end
        
        
        function saveExecution(runManager, fileName)
            % SAVEEXECUTION saves the summary of each execution to an
            % execution database, a CSV file named execution.csv in the
            % provenance_storage_directory with the columns: runId,
            % filePath, startTime, endTime, publishedTime, packageId, tag,
            % user, subject, hostId, operatingSystem, runtime, moduleDependencies, 
            % console, errorMessage.
            %   fileName - the name of the execution database
            
            runID = char(runManager.execution.execution_id);
            filePath = char(runManager.execution.software_application);
            startTime = char(runManager.execution.start_time);
            endTime = char(runManager.execution.end_time);
            publishedTime = char(runManager.execution.publish_time);
            packageId = char(runManager.execution.execution_id);
            tag = runManager.execution.tag; % Todo: a set of tag values         
            % added on Sept-17-2015
            user = char(runManager.execution.account_name);
            % changed on Oct-20-2015
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
            moduleDependencies = char(runManager.execution.module_dependencies); % Todo:
            console = ''; % Todo:
            errorMessage = char(runManager.execution.error_message);
            % added on Oct-13-2015
            runManager.last_sequence_number = runManager.last_sequence_number+1;
            seqNo = num2str(runManager.last_sequence_number);
            
            formatSpec = runManager.configuration.execution_db_write_format;
           
            curDir = pwd();
            cd(runManager.configuration.provenance_storage_directory);
            if exist(fileName, 'file') ~= 2
                [fileId, message] = fopen(fileName,'w');
                if fileId == -1
                    disp(message);
                end
                fprintf(fileId, formatSpec, ...,
                    'runId', 'filePath', 'startTime', 'endTime', ...,
                    'publishedTime', 'packageId', 'tag', 'user', ...,
                    'subject', 'hostId', 'operatingSystem', 'runtime', ...,
                    'moduleDependencies', 'console', 'errorMessage', 'runNumber'); % write header
                fprintf(fileId,formatSpec, ...,
                    runID, filePath, startTime, endTime, ...,
                    publishedTime, packageId, tag, user, ...,
                    subject, hostId, operatingSystem, runtime, ...,
                    moduleDependencies, console, errorMessage, seqNo); % write the metadata for the current execution
                fclose(fileId); 
            else
                [fileId, message] = fopen(fileName,'a');
                if fileId == -1
                    disp(message);
                end
                fprintf(fileId,formatSpec, ...,
                    runID, filePath, startTime, endTime, ...,
                    publishedTime, packageId, tag, user, ...,
                    subject, hostId, operatingSystem, runtime, ...,
                    moduleDependencies, console, errorMessage, seqNo); % write the metadata for the current execution     
                fclose(fileId); 
            end
            cd(curDir);
        end
       
        
        function [execMetaMatrix, header] = getExecMetadataMatrix(runManager)
            % GETEXECMETADATAMATRIX returns a matrix storing the
            % metadata summary for all executions from the exeucton
            % database.
            %   runManager - 
            formatSpec = runManager.configuration.execution_db_read_format;
            [fileId, message] = fopen(runManager.configuration.execution_db_name, 'r');
            if fileId == -1
                disp(message); 
            else
                header = textscan(fileId, formatSpec, 1, 'Delimiter', ',');
                execMetaData = textscan(fileId, formatSpec, 'Delimiter',',');
                fclose(fileId);
 
                % Convert a cell array to a matrix
                execMetaMatrix = [execMetaData{[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]}];
            end
        end
        
        
        function stmtStruct = getRDFTriple(runManager, filePath, p)
           % GETRDFTRIPLE get all related subjects related to a given property from all
           % triples contained in a resourcemap.
           %  filePath - the path to the resourcemap
           %  p - the given property of a RDF triple
           
           import org.dataone.util.NullRDFNode;
           import org.dataone.vocabulary.PROV;
           import org.dspace.foresite.Predicate;
           import com.hp.hpl.jena.graph.Node;
           import com.hp.hpl.jena.graph.Triple;
           import com.hp.hpl.jena.rdf.model.Model;
           import com.hp.hpl.jena.rdf.model.ModelFactory;
           import com.hp.hpl.jena.rdf.model.Property;
           import com.hp.hpl.jena.rdf.model.RDFNode;
           import com.hp.hpl.jena.rdf.model.Statement;
           import com.hp.hpl.jena.rdf.model.StmtIterator;
           import com.hp.hpl.jena.util.FileManager;
           import java.io.InputStream;
           import java.util.HashSet;
           import java.util.ArrayList;
           
           % Read the RDF/XML file
           fm = FileManager.get();
           in = fm.open(filePath);          
           if isempty(in) == 1 
               error('File: %s not found.', filePath);
           end         
           model = ModelFactory.createDefaultModel(); % Create an empty model
           model.read(in, '');
           queryPredicate= model.createProperty(p.getNamespace(), p.getName());
           stmts = model.listStatements([], queryPredicate, NullRDFNode.nullRDFNode); % null, (RDFNode)null
           
           i = 1;
           while (stmts.hasNext()) 
	            s = stmts.nextStatement();
	       	    t = s.asTriple();        
                
                % Create a table for files to be published in a datapackage 
                if t.getSubject().isURI()
                    stmtStruct(i,1).Subject = char(t.getSubject().getLocalName());
                elseif t.getSubject().isBlank()
                    stmtStruct(i,1).Subject = char(t.getSubject().getBlankNodeId());
                else
                    stmtStruct(i,1).Subject = char(t.getSubject().getName());
                end
                
                stmtStruct(i,1).Predicate = char(t.getPredicate().toString());
                
                if t.getObject().isURI()
                    stmtStruct(i,1).Object = char(t.getObject().getLocalName()); % Question: whether it is good to use localName here? In which cases are good?
                elseif t.getObject().isBlank()
                    stmtStruct(i,1).Object = char(t.getObject().getBlankNodeId());
                else
                    stmtStruct(i,1).Object = char(t.getObject().getName());
                end
                
                i = i + 1;
           end         
        end
             
        function [wasGeneratedByStruct, usedStruct, hadPlanStruct, qualifiedAssociationStruct, wasAssociatedWithPredicateStruct, userList, rdfTypeStruct] = getRelationships(runManager)
           % GETRELATIONSHIPS get the relationships from the resourceMap
           % including prov:used, prov:hadPlan, prov:qualifiedAssociation,
           % prov:wasAssociatedWith, and rdf:type
            
           import org.dataone.util.NullRDFNode;
           import org.dataone.vocabulary.PROV;
           import org.dspace.foresite.Predicate;
           import com.hp.hpl.jena.rdf.model.Property;
           import com.hp.hpl.jena.rdf.model.RDFNode;
           import com.hp.hpl.jena.vocabulary.RDF;
           
           % Query resource map                           
           resMapFileName = strtrim(ls('*.rdf')); % list the reosurceMap.rdf and remove the whitespace and return characters  
           wasGeneratedByPredicate = PROV.predicate('wasGeneratedBy');           
           wasGeneratedByStruct = runManager.getRDFTriple(resMapFileName, wasGeneratedByPredicate);                  
           
           usedPredicate = PROV.predicate('used');
           usedStruct = runManager.getRDFTriple(resMapFileName, usedPredicate); 
          
           hadPlanPredicate = PROV.predicate('hadPlan');
           hadPlanStruct = runManager.getRDFTriple(resMapFileName, hadPlanPredicate); 
           
           qualifiedAssociationPredicate = PROV.predicate('qualifiedAssociation');
           qualifiedAssociationStruct = runManager.getRDFTriple(resMapFileName, qualifiedAssociationPredicate);
           
           wasAssociatedWithPredicate = PROV.predicate('wasAssociatedWith');
           wasAssociatedWithPredicateStruct = runManager.getRDFTriple(resMapFileName, wasAssociatedWithPredicate);
           userList = wasAssociatedWithPredicateStruct.Object;
           
           rdfTypePredicate = runManager.asPredicate(RDF.type, 'rdf');
           rdfTypeStruct = runManager.getRDFTriple(resMapFileName, rdfTypePredicate);    
           
        end       
    end
    
    methods (Static)
        function runManager = getInstance(configuration)
            % GETINSTANCE returns an instance of the RunManager by either
            % creating a new instance or returning an existing one.
                        
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.run.RunManager;
           
            % Set all jars under lib/java/ to the java dynamic class path
            % (double check !)
            % RunManager.setJavaClassPath();
                       
            warning off MATLAB:dispatcher:nameConflict;
            
            % Set the java class path
            RunManager.setMatlabPath();
            
            % Set the overloaded io functions paths
            RunManager.setIOFunctionPath();
            
            warning on MATLAB:dispatcher:nameConflict;

            % Create a default configuration object if one isn't passed in
            if ( nargin < 1 )
                configuration = Configuration();               
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
            % $matalab-dataone/lib to the java class path
            
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
            % $matalab-dataone/lib/matlab to the Matlab path
            
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
            % $matalab-dataone/src/matlab/overloaded_functions/io to the top of Matlab path
            
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
            % GETDATAPACKAGE get the data package from the runManager
            pkg = runManager.dataPackage;
        end
        
        
        function d1_cn_resolve_endpoint = getD1_CN_Resolve_Endpoint(runManager)
            % GETD1CNRESOLVEENDPOINT get the dataone CN resolve endpoint
            % from the runManager
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
            
                % Set the manager.last_sequence_number based on execution_db_name last
                % sequence number
                if ( exist(runManager.configuration.execution_db_name, 'file') ~= 2 )
                    runManager.last_sequence_number = 0; 
                else
                    [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
                    if ~isempty(execMetaMatrix)
                        lastRow = execMetaMatrix(end,:);
                        lastSeqNum = lastRow{1,end};
                        runManager.last_sequence_number = str2num(lastSeqNum);
                    else
                        runManager.last_sequence_number = 0; 
                    end
                end
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
            % execution of the program, and a graph of their relationships
            % is produced using the W3C PROV ontology standard 
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
                
            % Initialize a new Execution for this run
            runManager.execution = Execution();
            runManager.execution.execution_input_ids = {};
            runManager.execution.execution_output_ids = {};
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

            % Record the starting time when record() started 
            runManager.execution.start_time = datestr(now, 'yyyymmddTHHMMSS');        
               
            if ( runManager.recording )
                warning(['A RunManager session is already active. Please call ' ...
                         'endRecord() if you wish to close this session']);
                  
            end                
           
            % Compute script_base_name if it is not assigned a value
            if isempty( runManager.configuration.script_base_name )
                [pathstr,script_base_name,ext] = ...
                    fileparts(runManager.execution.software_application);
                runManager.configuration.script_base_name = ...
                    strtrim(script_base_name);      
            end
                     
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
            
            warning off MATLAB:dispatcher:nameConflict;
            addpath(runManager.execution.execution_directory);
            warning on MATLAB:dispatcher:nameConflict;
            
            % Add a D1Object to the execution objects map for the script
            % itself
            import org.dataone.client.v2.D1Object;
            pid = char(java.util.UUID.randomUUID());
            d1Object = D1Object(pid, 'text/plain', ...
                runManager.execution.software_application);
            runManager.execution.execution_objects(d1Object.identifier) = ...
                d1Object;
                        
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
                
                % for stack_item = 1:length(runtimeError.stack)
                %     disp(['Error in function ' ...
                %         runtimeError.stack(stack_item).name ' in file ' ...
                %         runtimeError.stack(stack_item).file ' on line ' ...
                %         num2str(runtimeError.stack(stack_item).line)]);
                % end
            end
          
        end
        
        
        function endRecord(runManager)
            % ENDRECORD Ends the recording of an execution (run).
            
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.client.v2.itk.D1Object;
            import org.dataone.client.v2.itk.DataPackage;
            import org.dataone.client.run.NamedConstant;
            import java.io.File;
            import javax.activation.FileDataSource;
            import org.dataone.client.v1.types.D1TypeBuilder;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import java.net.URI;
            import org.dataone.util.ArrayListWrapper;
            
            % Stop recording
            runManager.recording = false;
            runManager.prov_capture_enabled = false;
               
            % Get submitter and MN node reference
            submitter = runManager.execution.get('account_name');
            mnNodeId = runManager.configuration.get('target_member_node_id');
                     
            % Generate yesWorkflow image outputs
            runManager.callYesWorkflow(runManager.execution.software_application, runManager.execution.execution_directory);
                   
            % Record the ending time when record() ended using format 30 (ISO 8601)'yyyymmddTHHMMSS'             
            runManager.execution.end_time = datestr(now, 'yyyymmddTHHMMSS');

            % Save the metadata for the current execution
            runManager.saveExecution(runManager.configuration.execution_db_name);   
            
            % Serialize the execution object to local file system in the
            % execution_directory
            execution_serialized_object = [runManager.execution.execution_id '.mat'];
            exec_destination = [runManager.execution.execution_directory filesep execution_serialized_object];
            executionObj = runManager.execution;
            save(char(exec_destination), 'executionObj');
            
             % Build a D1 datapackage
            pkg = runManager.buildPackage2( submitter, mnNodeId, runManager.execution.execution_directory );        
            
            % Clear runtime input/output sources
            runManager.execution.execution_input_ids = {};
            runManager.execution.execution_output_ids = {};
            
            % Unlock the RunManager instance
            munlock('RunManager');            
            clear RunManager;
        end
    
        
        function runs = listRuns(runManager, varargin)
            % LISTRUNS Lists prior executions (runs) and information about them from executions metadata database.
            %   quiet -- control the output or not
            %   startDate -- the starting timestamp for an execution
            %   endDate -- the ending timestamp for an execution
            %   tag -- a tag given to an execution 
            %   runNumber -- a sequence number given to an execution
       
            persistent listRunsParser
            if isempty(listRunsParser)
                listRunsParser = inputParser;
               
                addParameter(listRunsParser,'quiet', false, @islogical);
                addParameter(listRunsParser,'startDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(listRunsParser,'endDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(listRunsParser,'tag', '', @iscell);
                checkSequenceNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(listRunsParser,'runNumber', '', checkSequenceNumber);
            end
            parse(listRunsParser,varargin{:})
            
            quiet = listRunsParser.Results.quiet;
            startDate = listRunsParser.Results.startDate;
            endDate = listRunsParser.Results.endDate;
            tags = listRunsParser.Results.tag;
            runNumber = listRunsParser.Results.runNumber;
            
            if runManager.configuration.debug
                listRunsParser.Results
            end
            
            % Read the exeuction metadata summary from the exeuction
            % metadata database
            [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
           
            % When the database is empty, show no rows and return
            if ( isempty(execMetaMatrix) )
                runs = {};
                
                if ~quiet
                    fprintf('\n%s\n', 'There are no runs to display yet.');
                end
                return;                
            end
            % Initialize the logical cell arrays for the next call for listRuns()
            dateCondition = false(size(execMetaMatrix, 1), 1);
            tagsCondition = false(size(execMetaMatrix, 1), 1);
            runNumberCondition = false(size(execMetaMatrix, 1), 1);
            allCondition = true(size(execMetaMatrix, 1), 1);
            
            % Process the query constraints
            startDateFlag = false;
            endDateFlag = false;
                
            if isempty(startDate) ~= 1                
                startDateFlag = true;
            end
                            
            if isempty(endDate) ~= 1                
                endDateFlag = true;
            end
                
            if startDateFlag && endDateFlag
                startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');                   
                % Extract multiple rows from a matrix 
                startCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') >= startDateNum;
                endColCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') <= endDateNum;
                dateCondition = startCondition & endColCondition;
                allCondition = allCondition & dateCondition;
            elseif startDateFlag == 1
                startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                % Extract multiple rows from a matrix 
                dateCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') >= startDateNum; % Column 3 for startDate
                allCondition = allCondition & dateCondition;
            elseif endDateFlag == 1
                endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');
                dateCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') <= endDateNum; % Column 4 for endDate
                allCondition = allCondition & dateCondition;
            end
                        
            % Process the query parameter "tags"            
            if ~isempty(tags)               
                tagsArray = char(tags);
                tagsCondition = ismember(execMetaMatrix(:,7), tagsArray); % compare the existence between two arrays (column 7 for tag)
                % allCondition = dateCondition & tagsCondition; % Logical and operator
                allCondition = allCondition & tagsCondition;
            end

            if ~isempty(runNumber)
                snValue = num2str(runNumber);
                runNumberCondition = strcmp(execMetaMatrix(:,16), snValue);
                allCondition = allCondition & runNumberCondition;
            end
            
            % Extract multiple rows from a matrix satisfying the allCondition
            runs = execMetaMatrix(allCondition, :);
            runsToDisplay = execMetaMatrix(allCondition, [16,6,2,7,3,4,5]);
               
            % Convert the full path of a script to a base file name in
            % listRus(). The full path is displayed in viewRun()
            numOfRows = size(runsToDisplay, 1);
            for i=1:numOfRows
               fullName = runsToDisplay{i,3};
               name_array = strsplit(fullName, filesep);
               runsToDisplay{i,3} = name_array(end);
            end
            
            % Display
            if isempty(quiet) ~= 1 && quiet ~= 1
                % Convert a cell array to a table with headers                 
               % tableForSelectedRuns = cell2table(runs,'VariableNames', [header{:}]);  
                tableForSelectedRuns = cell2table(runsToDisplay,'VariableNames', {'runNumber', 'packageId', 'scriptName', 'tags', 'startDate', 'endDate', 'publishDate'}); 
                disp(tableForSelectedRuns);                      
            end          
        end
        
        function deleted_runs = deleteRuns(runManager, varargin)
            % DELETERUNS Deletes prior executions (runs) from the stored
            % list.    
            %   runIdList -- the list of runIds for executions to be deleted
            %   startDate -- the starting timestamp for an execution to be deleted
            %   endDate -- the ending timestamp for an execution to be deleted
            %   tag -- a tag given to an execution to be deleted
            %   runNumber -- a sequence number given to an execution to be deleted
            %   noop -- control delete the exuecution from disk or not
            %   quiet -- control the output or not
            
            persistent deletedRunsParser
            if isempty(deletedRunsParser)
                deletedRunsParser = inputParser;
                
                addParameter(deletedRunsParser,'runIdList', '', @iscell);
                addParameter(deletedRunsParser,'startDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(deletedRunsParser,'endDate', '', @(x) any(regexp(x, '\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}')));
                addParameter(deletedRunsParser,'tag', '', @iscell);
                checkSequenceNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
                addParameter(deletedRunsParser,'runNumber', '', checkSequenceNumber);
                addParameter(deletedRunsParser,'noop', false, @islogical);
                addParameter(deletedRunsParser,'quiet',false, @islogical);
            end
            parse(deletedRunsParser,varargin{:})
            
            runIdList = deletedRunsParser.Results.runIdList;
            startDate = deletedRunsParser.Results.startDate;
            endDate = deletedRunsParser.Results.endDate;
            tags = deletedRunsParser.Results.tag;
            runNumber = deletedRunsParser.Results.runNumber;
            noop = deletedRunsParser.Results.noop;
            quiet = deletedRunsParser.Results.quiet;
            
            if runManager.configuration.debug
                deletedRunsParser.Results
            end
            
            % Read the exeuction metadata summary from the exeuction metadata database
            [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
                       
            % Initialize the logical cell arrays to have false value
            dateCondition = false(size(execMetaMatrix, 1), 1);
            runIdCondition = false(size(execMetaMatrix, 1), 1);
            tagsCondition = false(size(execMetaMatrix, 1), 1);
            runNumberCondition = false(size(execMetaMatrix, 1), 1);
            allDeleteCondition = true(size(execMetaMatrix, 1), 1);
            
            startDateFlag = false;
            endDateFlag = false;
                
            if isempty(startDate) ~= 1
                startDateFlag = true;
            end
                
            if isempty(endDate) ~= 1
                endDateFlag = true;
            end
            
            if startDateFlag && endDateFlag
                startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');                   
                startCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') >= startDateNum;
                endColCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') <= endDateNum;
                dateCondition = startCondition & endColCondition;
                allDeleteCondition = allDeleteCondition & dateCondition;
            elseif startDateFlag == 1
                startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                dateCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') >= startDateNum; % logical vector for rows to delete  
                allDeleteCondition = allDeleteCondition & dateCondition;
            elseif endDateFlag == 1
                endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');
                dateCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') <= endDateNum;   
                allDeleteCondition = allDeleteCondition & dateCondition;
            end
                        
            if ~isempty(runIdList)
                runIdArray = char(runIdList);
                runIdCondition = ismember(execMetaMatrix(:,1), runIdArray); % compare the existance between two arrays
                allDeleteCondition = allDeleteCondition & runIdCondition;
            end
                
            if ~isempty(tags)
                tagsArray = char(tags);
                tagsCondition = ismember(execMetaMatrix(:,7), tagsArray); % compare the existence between two arrays (column 7 for tag)
                allDeleteCondition = allDeleteCondition & tagsCondition;
            end
           
            if ~isempty(runNumber)
                snValue = num2str(runNumber);
                runNumberCondition = strcmp(execMetaMatrix(:,16), snValue);
                allDeleteCondition = allDeleteCondition & runNumberCondition;
            end
           
            % Extract multiple rows from a matrix satisfying the allCondition
            deleted_runs = execMetaMatrix(allDeleteCondition, :);
            
            % Delete the selected runs from the execution matrix and update the exeucution database
            if  noop == 1
                % Show the selected run list only when quiet is turned on
                if isempty(quiet) ~= 1 && quiet ~= 1
                    % Convert a cell array to a table with headers    
                    disp('The following runs are matched and to be deleted:');
                    tableForSelectedRuns = cell2table(deleted_runs,'VariableNames', [header{:}]);  
                    disp(tableForSelectedRuns);                      
                end
            else
                % Show the selected run list and do the deletion operation                
                selectedIdSet = deleted_runs(:,1);
            
                % Delete the selected runs
                for k = 1:length(selectedIdSet)                   
                    selectedRunDir = fullfile( ...
                        runManager.configuration.provenance_storage_directory, ...
                        'runs', selectedIdSet{k});
                    if exist(selectedRunDir, 'dir') == 7 
                        [success, errMessage, messageID] = rmdir(selectedRunDir, 's');
                        if success == 1
                            fprintf('Succeed in deleting the directory %s\n', selectedRunDir);                         
                        else
                            fprintf('Error in deleting a directory %s and the error message is %s \n', ...
                            selectedRunDir, errMessage);
                        end 
                    else
                        fprintf('The %s directory to be deleted not exist.\n', selectedRunDir);
                    end
                end

                % Update the execuction metadata matrix by removing the deleted rows and write the update metadata back to the execution database                               
                execMetaMatrix(allDeleteCondition, :) = []; % deleted the selected rows
                    
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
        end
           
        function results = view(runManager, varargin)
           % VIEW Displays detailed information about a data package that
           % is the result of an execution (run).
 
           % Display a warning message to the user
           if runManager.configuration.debug
               disp('Warning: There is no scientific metadata in this data package.');
           end
           
           persistent viewRunsParser
           if isempty(viewRunsParser)
               viewRunsParser = inputParser;
               
               addParameter(viewRunsParser,'packageId', '', @ischar);   
               checkSequenceNumber = @(x) ischar(x) || (isnumeric(x) && isscalar(x) && (x > 0));
               addParameter(viewRunsParser,'runNumber', '', checkSequenceNumber);
               addParameter(viewRunsParser,'tag', '', @iscell);
               addParameter(viewRunsParser,'sections', '', @iscell);
           end
           parse(viewRunsParser,varargin{:})
            
           packageId = viewRunsParser.Results.packageId;
           runNumber = viewRunsParser.Results.runNumber;
           tags = viewRunsParser.Results.tag;
           sections = viewRunsParser.Results.sections;
            
           if runManager.configuration.debug
               viewRunsParser.Results
           end
           
           % Read the exeuction metadata summary from the exeuction metadata database
           [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
           
           % Initialize the logical cell arrays for the next call for listRuns() 
           packageIdCondition = false(size(execMetaMatrix, 1), 1);          
           runNumberCondition = false(size(execMetaMatrix, 1), 1);   
           tagsCondition = false(size(execMetaMatrix, 1), 1);
           allCondition = true(size(execMetaMatrix, 1), 1);
                   
           % Select runs based on the packageID. 
           if(isempty(packageId) ~= 1)
               packageIdCondition = strcmp(execMetaMatrix(:,6), packageId); % Column 6 in the execution matrix for packageId
               allCondition = allCondition & packageIdCondition;
           end
           
           % Process the query parameter "tags"            
           if ~isempty(tags)               
               tagsArray = char(tags);
               tagsCondition = ismember(execMetaMatrix(:,7), tagsArray); % compare the existence between two arrays (column 7 for tag)
               allCondition = allCondition & tagsCondition; % Logical and operator
           end

           if ~isempty(runNumber)              
               snValue = num2str(runNumber);
               runNumberCondition = strcmp(execMetaMatrix(:,16), snValue);                              
               allCondition = allCondition & runNumberCondition;
           end
            
           % Extract multiple rows from a matrix satisfying the allCondition
           selectedRuns = execMetaMatrix(allCondition, :);
           if isempty(selectedRuns)
               error('No runs can be found as a match.');
           end
            
           seqNo = selectedRuns{1, 16}; % Todo: handle multiple views returned. Now assum only one run is returned
           packageId = selectedRuns{1, 6};

           % Read information from the selectedRuns returned by the execution summary database
           filePath = selectedRuns{1, 2};
           [pathstr,scriptName,ext] = fileparts(filePath);
           
           if isempty(selectedRuns{1,5} ) ~= 1              
               % publishedTime = datetime( selectedRuns{1,5}, 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ssZ');
               dateNum = datenum(selectedRuns{1,5}, 'yyyymmddTHHMMSS');
               publishedTime = datestr( dateNum, 'yyyy-mm-dd HH:MM:SS');
           else
               publishedTime = 'Not Published';
           end
           
           dateNum = datenum( selectedRuns{1,3}, 'yyyymmddTHHMMSS' ); 
           startTime = datestr( dateNum, 'yyyy-mm-dd HH:MM:SS'); % todo: add time zone and datetime is not available in R2014b version
           dateNum = datenum(selectedRuns{1,4} , 'yyyymmddTHHMMSS');
           endTime = datestr( dateNum, 'yyyy-mm-dd HH:MM:SS');
           % startTime = datetime( selectedRuns{1,3}, 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ssZ');
           % endTime = datetime( selectedRuns{1,4}, 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ssZ' );
                 
           % Compute the detailStruct for the details_section 
           fieldnames = {'Tag', 'RunSequenceNumber', 'PublishedDate', 'PublishedTo', ...
                         'RunByUser', 'AccountSubject', 'RunId', 'DataPackageId', ...
                         'HostId', 'OperatingSystem', 'Runtime', 'Dependencies', ...
                         'RunStartTime','RunEndingTime', 'ErrorMessageFromThisRun'};
           values = {selectedRuns{1,7}, seqNo, publishedTime, runManager.configuration.target_member_node_id, ...
                     selectedRuns{1,8}, selectedRuns{1,9}, selectedRuns{1,1}, selectedRuns{1,6}, ...
                     selectedRuns{1,10}, selectedRuns{1,11}, selectedRuns{1,12}, selectedRuns{1,13}, ...
                     char(startTime), char(endTime), selectedRuns{1,15}};                   
           detailStruct = struct;
           for i=1:length(fieldnames)
               detailStruct.(fieldnames{i}) = values{i};
           end

           % Deserialize the execution object from the disk
           
           % Load the stroed execution given the directory name
           exec_file_base_name = [packageId '.mat'];
           stored_execution = load(fullfile( ...
               runManager.configuration.provenance_storage_directory, ...
               'runs', ...
               packageId, ...
               exec_file_base_name));
           
           % Assign deserialized execution to runManager.execution
           runManager.execution = stored_execution.executionObj(1);
           
           import org.apache.commons.io.FileUtils;
           
           % Compute the used struct for the used_section
           for i=1:length(runManager.execution.execution_input_ids)
               inId = runManager.execution.execution_input_ids{i};
               
               inD1Object = runManager.execution.execution_objects(inId);
               in_d1_sysmeta = inD1Object.system_metadata;
               in_file_size = in_d1_sysmeta.getSize;
               in_file_name = in_d1_sysmeta.getFileName;
               in_file_metadata = dir(inD1Object.full_file_path);
               
               usedFileStruct(i,1).LocalName = char(in_file_name);     
               fsize = FileUtils.byteCountToDisplaySize(in_file_size.longValue());                     
               usedFileStruct(i,1).Size = char(fsize); 
               usedFileStruct(i,1).ModifiedTime = in_file_metadata.date;     
           end
           
           % Compute the wasGeneratedBy struct for the wasGeneratedBy_section  
           for j=1:length(runManager.execution.execution_output_ids)
               outId = runManager.execution.execution_output_ids{j};
               
               outD1Object = runManager.execution.execution_objects(outId);
               out_d1_sysmeta = outD1Object.system_metadata;
               out_file_size = out_d1_sysmeta.getSize;
               out_file_name = out_d1_sysmeta.getFileName;
               out_file_metadata = dir(outD1Object.full_file_path);
               
               generatedFileStruct(j,1).LocalName = char(out_file_name);     
               fsize = FileUtils.byteCountToDisplaySize(out_file_size.longValue());                     
               generatedFileStruct(j,1).Size = char(fsize); 
               generatedFileStruct(j,1).ModifiedTime = out_file_metadata.date;     
           end
           
           results = {detailStruct, usedFileStruct, generatedFileStruct};
 
           more on; % Enable more for page control
           
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
           
           % Display different sections
           if showDetails == 1
               fprintf('\n[DETAILS]: Run details\n');
               fprintf('-------------------------\n');
               fprintf('"%s" was executed on %s\n', scriptName, char(startTime));           
               disp(detailStruct);
           end
                    
           if showUsed == 1    
               fprintf('\n\n[USED]: %d Items used by this run\n', length(usedFileStruct));
               fprintf('------------------------------------\n');
               TableForFileUsed = struct2table(usedFileStruct); % Convert a struct to a table
               disp(TableForFileUsed);  
           end 
           
           if showGenerated == 1                    
               fprintf('\n\n[GENERATED]: %d Items used by this run\n', length(generatedFileStruct));
               fprintf('------------------------------------------\n');              
               TableForFileWasGeneratedBy = struct2table(generatedFileStruct); % Convert a struct to a table
               disp(TableForFileWasGeneratedBy);               
           end
           
           more off; % terminate more           
        end
          
        function package_id = publish(runManager, packageId)
            % PUBLISH Uploads a data package from a folder on disk
            % to the configured DataONE Member Node server.
            
            import java.lang.String;
            import java.lang.Boolean;
            import java.lang.Integer;
            import org.dataone.client.v2.MNode;
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.v2.itk.DataPackage;           
            import org.dataone.service.types.v2.SystemMetadata;
            import org.dataone.service.types.v1.Session;
            import org.dataone.service.util.TypeMarshaller;
            import org.dataone.service.types.v1.AccessPolicy;
            import org.dataone.service.types.v1.util.AccessUtil;
            import org.dataone.service.types.v1.Permission;            
            import org.dataone.service.types.v1.ReplicationPolicy;
            import org.dataone.service.types.v1.Subject;
            import org.dataone.configuration.Settings;
            
            prov_dir = runManager.configuration.get('provenance_storage_directory');
            curRunDir = fullfile(prov_dir, 'runs', packageId);
         
            if exist(curRunDir, 'dir') ~= 7
                error([' A directory was not found for execution identifier: ' packageId]);               
            end                 
            
            % Get a MNode instance to the Member Node
            try                
                % Deserialize the execution object from the disk
                
                % Load the stroed execution given the directory name
                exec_file_base_name = [packageId '.mat'];
                stored_execution = load(fullfile( ...
                    runManager.configuration.provenance_storage_directory, ...
                    'runs', ...
                    packageId, ...
                    exec_file_base_name));
                
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
                
                pkg = runManager.buildPackage2( submitter, mnNodeId, runManager.execution.execution_directory );    
                                
                % Get authenticate token or X509 certificate 
                auth_token = runManager.configuration.get('authentication_token');
             
                [certificate, standardizedName] = runManager.getCertificate();
                
                if ~isempty(auth_token)             
                    D1Client.setAuthToken(auth_token);
                elseif ~isempty(certificate)                   
                    runManager.configuration.submitter = standardizedName;
                else
                    error('Authenticate token or X509 certificate need to be set before calling publish().');
                end
               
                % Get D1 cilogon certificate stored at /tmp/x509up_u501
                % certificate = runManager.getCertificate();
                % Pull the subject DN out of the certificate for use in system metadata
                %runManager.configuration.submitter = certificate.getSubjectDN().toString();
                             
                % Set the CN URL in the Java Client Library
                if ( ~isempty(runManager.configuration.coordinating_node_base_url) )
                    Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                        runManager.configuration.coordinating_node_base_url); 
                end
                
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
                 
                % submitterStr = runManager.configuration.get('submitter');
                targetMNodeStr = runManager.configuration.get('target_member_node_id');
                
                submitter = Subject();
                submitter.setValue(runManager.execution.account_name); % Todo: use account_name as the value of submitter now. But need to investigate if auth_token has the submitter information
               
                % Upload each data object in the execution_objects map
                identifiers = keys(runManager.execution.execution_objects);
                d1objects = values(runManager.execution.execution_objects);
                
                for k = 1: length(identifiers)
                    
                    d1_object_id = identifiers{k};
                    d1_object = d1objects{k};
                    d1_object_format = d1_object.format_id;
                    
                    if runManager.configuration.debug
                        fprintf('Uploading file: %s and file format: %s\n', d1_object_id, d1_object_format);
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
                        fprintf('d1Obj.rightHolder=%s\n', char(v2SysMeta.getRightsHolder().getValue()));
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
                        permsArrary = javaArray('org.dataone.service.types.v1.Permission', 1);
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
                    
                    % Upload the data to the MN using create(), checking for success and a returned identifier       
                    % pid = cnNode.reserveIdentifier(session,v2SysMeta.getIdentifier()); 
                    % if isempty(pid) ~= 1
                    pid = v2SysMeta.getIdentifier();
                    returnPid = mnNode.create([], pid, dataSource.getInputStream(), v2SysMeta);  
                    if isempty(returnPid) ~= 1
                        fprintf('Success uploaded %s\n.', char(returnPid.getValue()));
                    else
                        % TODO: Process the error correctly.
                        error('Error on returned identifier %s', char(v2SysMeta.getIdentifier()));
                    end
                    % else
                        % TODO: Process the error correctly.
                        % error('Error on duplicate identifier %s', v2SysMeta.getIdentifier());
                    % end
                end
                
                package_id = packageId; 
         
            catch runtimeError 
                error(['Could not create member node reference: ' runtimeError.message]);
                runManager.execution.error_message = [runManager.execution.error_message ' ' runtimeError.message];
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

        
        function science_memtadata = getMetadata(runManager, runId)
            % GETMETADATA retrieves the metadata describing data objects of an execution
            
            % TODO: implement this
        end

        
        function science_memtadata = putMetadata(runManager, runId, file)
            % PUTMETADATA stores (or replaces) the metadata describing data objects of an execution
            
            % TODO: implement this
        end

    end

end

