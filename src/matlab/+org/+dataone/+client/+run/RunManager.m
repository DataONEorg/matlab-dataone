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
               
        % The provenance directory for an execution
        runDir;
        
        % Control switch for printing debug messaging 
        debug = false;
                       
        % runID
        runId;
        
        % The name for the execution database
        executionDatabaseName = 'executions.csv';
        
        % The name for the yesWorkflow configuration file
        PROCESS_VIEW_PROPERTY_FILE_NAME;
        DATA_VIEW_PROPERTY_FILE_NAME;
        COMBINED_VIEW_PROPERTY_FILE_NAME;
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
        
        % DataONE CN URL
        CN_URL; 
        
        % DataONE CN URI resolve endpoint 
        D1_CN_Resolve_Endpoint;
        
        % Current workflow identifier
        wfIdentifier;
        
        % Predicate for the rdf:type
        aTypePredicate;
        
        % Current execution instance URI
        execURI;
        
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
       
    end
   
    methods (Access = private)

        function manager = RunManager(configuration)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            % The RunManager class manages outputs of a script based on the
            % settings in the given configuration passed in.            
            import org.dataone.client.configure.Configuration;
            manager.configuration = configuration;
            configuration.saveConfig();
            manager.init();
            mlock; % Lock the RunManager instance to prevent clears          
        end
        
        
        function predicate = asPredicate(runManager, property, prefix)
            % ASPREDICATE  Given a Jena Property and namespace prefix, create an ORE Predicate. 
            % This allows us to use the Jena vocabularies.
            %   property -- predicate
            %   prefix -- namespace prefix
            import com.hp.hpl.jena.rdf.model.Property;
            import org.dspace.foresite.Predicate;
            import java.net.URI;
             
            predicate = Predicate();
            if runManager.debug
                fprintf('property.localName = %s\n', char(property.getLocalName()));
            end
            predicate.setName(property.getLocalName());
            %predicate.setNamespace(property.getNamespace()); % There is an error here !
            if isempty(prefix) ~= 1
                predicate.setPrefix(prefix);               
            end
            predicate.setURI(URI(property.getURI()));
            
            if runManager.debug
                fprintf('predicate.URI = %s\n', char(predicate.getURI()));
                fprintf('predicate.nameSpace = %s\n', char(predicate.getNamespace()));
            end
        end
        
        
        function cn_url = getD1UriPrefix(runManager)
            % GETD1URIPREFIX Get the URL for dataone coordinator node 
            import org.dataone.configuration.Settings;
            import org.dataone.client.v2.itk.D1Client;
            
            cn_url = Settings.getConfiguration().getString('D1Client.CN_URL');
            
            if runManager.debug
                fprintf('char(cn_url)=%s\n', char(cn_url));
            end

        end
        
        
        function configYesWorkflow(runManager, path)
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
            import org.yesworkflow.extract.HashmapMatlabWrapper;
            import org.yesworkflow.Language;
            
            config = HashmapMatlabWrapper;
            config.put('language', Language.MATLAB);
            runManager.extractor = runManager.extractor.configure(config);         
          
            % Set generate_workflow_graphic to be true
            runManager.configuration.generate_workflow_graphic = true;
        end
        
        
        function certificate = getCertificate(runManager)
            % GETCERTIFICATE Gets a certificate 
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
            
            % Get a certificate for the Root CA           
            certificate = CertificateManager.getInstance().loadCertificate();
            
            if runManager.debug
                fprintf('Client subject is: %s\n', char(certificate.getSubjectDN()));  
            end
        end
        
        
        function captureProspectiveProvenanceWithYW(runManager)
            % CAPTUREPROSPECTIVEPROVENANCEWITHYW captures the prospective provenance using YesWorkflow 
            % by scannning the inline yesWorkflow comments.
         
            import java.io.BufferedReader;
            import org.yesworkflow.annotations.Annotation;
            import org.yesworkflow.model.Program;
            import org.yesworkflow.model.Workflow;
            import java.io.File;
            import java.io.FileReader;
            import java.util.List;
            import java.util.HashMap;
            import org.yesworkflow.config.YWConfiguration;
            
            try
                % Read script content from disk
                script = File(runManager.execution.software_application);
                freader = FileReader(script);
                reader = BufferedReader(freader);
            
                % Use yw.properties for configuration                                     
                config = YWConfiguration();

                % Call YW-Extract module
                runManager.extractor = runManager.extractor.reader(reader); % April-version yesWorkflow
                annotations = runManager.extractor.extract().getAnnotations();
        
                % Call YW-Model module
                runManager.modeler = runManager.modeler.annotations(annotations);
                runManager.modeler = runManager.modeler.model();
                runManager.workflow = runManager.modeler.getModel().program; % April-version yesWorkflow
               
                % Call YW-Graph module
                if runManager.configuration.generate_workflow_graphic
                    import org.yesworkflow.graph.GraphView;
                    import org.yesworkflow.graph.CommentVisibility;
                    import org.yesworkflow.extract.HashmapMatlabWrapper;
                    import org.yesworkflow.graph.LayoutDirection;
                
                    runManager.grapher = runManager.grapher.workflow(runManager.workflow);
                    
                    % Set the working directory to be the run metadata directory for this run
                    curDir = pwd();
                    cd(runManager.runDir); 
                
                    % Generate YW.Process_View dot file                   
                    config.applyPropertyFile(runManager.PROCESS_VIEW_PROPERTY_FILE_NAME); 
                    gconfig = config.getSection('graph');
                    runManager.processViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();           
                   
                    % Generate YW.Data_View dot file                  
                    config.applyPropertyFile(runManager.DATA_VIEW_PROPERTY_FILE_NAME); 
                    gconfig = config.getSection('graph');
                    runManager.dataViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();
                   
                    % Generate YW.Combined_View dot file                   
                    config.applyPropertyFile(runManager.COMBINED_VIEW_PROPERTY_FILE_NAME);
                    gconfig = config.getSection('graph');
                    runManager.combinedViewDotFileName = gconfig.get('dotfile');
                    runManager.grapher.configure(gconfig);
                    runManager.grapher = runManager.grapher.graph();
                   
                    % Create yesWorkflow modelFacts prolog dump 
                    import org.yesworkflow.model.ModelFacts;
                    import org.yesworkflow.extract.ExtractFacts;
                    
                    modelFacts = runManager.modeler.getFacts();               
                    runManager.mfilename = [runManager.configuration.script_base_name  '_ywModelFacts.pl'];
                    fw = fopen(runManager.mfilename, 'w'); 
                    if fw == -1, error('Cannot write "%s%".',runManager.mfilename); end
                    fprintf(fw, '%s', char(modelFacts));
                    fclose(fw);
                    
                    % Create yewWorkflow extractFacts prolog dump
                    extractFacts = runManager.extractor.getFacts();              
                    runManager.efilename = [runManager.configuration.script_base_name  '_ywExtractFacts.pl'];
                    fw = fopen(runManager.efilename, 'w');    
                    if fw == -1, error('Cannot write "%s%".',runManager.efilename); end
                    fprintf(fw, '%s', char(extractFacts));
                    fclose(fw);
                   
                    cd(curDir); % go back to current working directory          
                end  
                
            catch ME      
            end      
        end
 
       
        function generateYesWorkflowGraphic(runManager)
            % GENERATEYESWORKFLOWGRAPHIC Generates yesWorkflow graphcis in pdf format. 
            
            position = strfind(runManager.processViewDotFileName, '.gv'); % get the index of '.gv'            
            processViewDotName = strtrim(runManager.processViewDotFileName(1:(position-1)));
            runManager.processViewPdfFileName = [processViewDotName '.pdf'];
            
            position = strfind(runManager.dataViewDotFileName, '.gv'); % get the index of '.gv'            
            dataViewDotName = strtrim(runManager.dataViewDotFileName(1:(position-1)));
            runManager.dataViewPdfFileName = [dataViewDotName '.pdf'];
            
            position = strfind(runManager.combinedViewDotFileName, '.gv'); % get the index of '.gv'            
            combViewDotName = strtrim(runManager.combinedViewDotFileName(1:(position-1)));
            runManager.combinedViewPdfFileName = [combViewDotName '.pdf'];
             
            % Convert .gv files to .pdf files
            if isunix    
                system(['/usr/local/bin/dot -Tpdf '  runManager.processViewDotFileName ' -o ' runManager.processViewPdfFileName]);
                system(['/usr/local/bin/dot -Tpdf '  runManager.dataViewDotFileName ' -o ' runManager.dataViewPdfFileName]);  
                system(['/usr/local/bin/dot -Tpdf '  runManager.combinedViewDotFileName ' -o ' runManager.combinedViewPdfFileName]); % for linux & mac platform, not for windows OS family             
            
                delete(runManager.processViewDotFileName);
                delete(runManager.dataViewDotFileName);
                delete(runManager.combinedViewDotFileName);
            end
        end
        
        
        function buildPackage(runManager, submitter, mnNodeId) 
            % BUILDPACKAGE  packages a datapackage for the current run
            % including the workflow script and yesWorkflow graphics
            import org.dataone.client.v1.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;            
            import org.dataone.client.run.NamedConstant;
            import org.dataone.client.v1.itk.ArrayListMatlabWrapper;
            import org.dataone.client.v1.types.D1TypeBuilder;
            import org.dataone.client.v1.itk.D1Object;
            import com.hp.hpl.jena.vocabulary.RDF;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import org.dataone.vocabulary.ProvONE_V1;
            import java.net.URI;
            import org.dspace.foresite.ResourceMap;
            import org.dataone.vocabulary.DC_TERMS;
            import java.io.File;
            import javax.activation.FileDataSource;
            
            % Get the base URL of the DataONE coordinating node server
            runManager.CN_URL = runManager.getD1UriPrefix(); 
            runManager.D1_CN_Resolve_Endpoint = [char(runManager.CN_URL) '/v1/resolve/'];
            
            % Record a data list for provOne:Data
            runManager.provONEdataURI = URI(ProvONE.Data.getURI());
                      
            % Create a D1Object for the program that we are running  
            fileId = File(runManager.execution.software_application);
            data = FileDataSource(fileId);           
            scriptFmt = 'text/plain';        
            wfId = Identifier;
            scriptNameArray = strsplit(runManager.execution.software_application,filesep);          
            wfId.setValue([runManager.configuration.script_base_name char(scriptNameArray(end))]);        
            programD1Obj = D1Object(wfId, data, D1TypeBuilder.buildFormatIdentifier(scriptFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(programD1Obj);
            
            % Create a D1 identifier for the workflow script  
            runManager.wfIdentifier = Identifier();
            scriptNameArray  = strsplit(runManager.execution.software_application,filesep);                     
            runManager.wfIdentifier.setValue([runManager.configuration.script_base_name '_' char(scriptNameArray (end))]);
            
            % Todo: how to generate the science meta for the workflow scripts ?
            % wfIdsList = ArrayListMatlabWrapper();
            % wfIdsList.add(runManager.wfIdentifier);   
            % runManager.wfMetaFileName = [runManager.configuration.script_base_name '_meta1.1'];
            % wfMetadataId = Identifier();
            % wfMetadataId.setValue(runManager.wfMetaFileName);
            % runManager.dataPackage.insertRelationship(wfMetadataId, wfIdsList);    
       
            % Record relationship identifying workflow identifier and URI as a provONE:Program
            runManager.aTypePredicate = runManager.asPredicate(RDF.type, 'rdf');
            provOneProgramURI = URI(ProvONE.Program.getURI());        
            runManager.dataPackage.insertRelationship(runManager.wfIdentifier.getValue(), runManager.aTypePredicate, provOneProgramURI);
            % Describe the workflow identifier with resovlable URI 
            wfSubjectURI = URI([runManager.D1_CN_Resolve_Endpoint char(runManager.wfIdentifier.getValue())]);
            runManager.dataPackage.insertRelationship(wfSubjectURI, runManager.aTypePredicate, provOneProgramURI);
           
            % Record relationship identifying execution id as a provone:Execution                              
            runManager.execURI = URI([runManager.D1_CN_Resolve_Endpoint  'execution_' runManager.runId]);
 
            runManager.associationSubjectURI = URI([runManager.D1_CN_Resolve_Endpoint 'A0_' char(java.util.UUID.randomUUID())]);
            provOneProgramURI = URI(ProvONE.Program.getURI());
            % Store the prov relationship: association->prov:hadPlan->program
            predicate = PROV.predicate('hadPlan');
            runManager.dataPackage.insertRelationship(runManager.associationSubjectURI, predicate, provOneProgramURI);
            % Record relationship identifying association id as a prov:Association
            provAssociationURI = URI(PROV.Association.getURI());
            runManager.dataPackage.insertRelationship(runManager.associationSubjectURI, runManager.aTypePredicate, provAssociationURI);
                        
            % Store the prov relationship: execution->prov:qualifiedAssociation->association
            provAssociationObjURI = URI(PROV.Association.getURI());
            predicate = PROV.predicate('qualifiedAssociation');
            runManager.dataPackage.insertRelationship(runManager.execURI, predicate, provAssociationObjURI);
            
            provOneExecURI = URI(ProvONE.Execution.getURI());           
            runManager.dataPackage.insertRelationship(runManager.execURI, runManager.aTypePredicate, provOneExecURI);  
                      
            % Store the ProvONE relationships for user
            runManager.userURI = URI([runManager.D1_CN_Resolve_Endpoint runManager.execution.account_name]);                 
            % Record the relationship between the Execution and the user
            predicate = PROV.predicate('wasAssociatedWith');
            runManager.dataPackage.insertRelationship(runManager.execURI, predicate, runManager.userURI);    
            % Record the relationship for association->prov:agent->"user"
            predicate = PROV.predicate('agent');
            runManager.dataPackage.insertRelationship(runManager.associationSubjectURI, predicate, runManager.userURI);
            % Record a relationship identifying the provONE:user
            provONEUserURI = URI(ProvONE.User.getURI());
            runManager.dataPackage.insertRelationship(runManager.userURI, runManager.aTypePredicate, provONEUserURI); 
            
             % YesWorkflow combined view image (.pdf)
            combinedViewId = Identifier();
            combinedViewId.setValue(runManager.combinedViewPdfFileName);
            combinedViewURI = URI([runManager.D1_CN_Resolve_Endpoint  runManager.combinedViewPdfFileName]);
            metaCombinedView = Identifier(); % metadata
            metaCombinedView.setValue([runManager.configuration.script_base_name '_combined_view.xml']);
            combinedViewIds = ArrayListMatlabWrapper;
            combinedViewIds.add(combinedViewId); 
                
            % YesWorkflow data view image (.pdf)
            dataViewId = Identifier();
            dataViewId.setValue(runManager.dataViewPdfFileName); 
            dataViewURI = URI([runManager.D1_CN_Resolve_Endpoint runManager.dataViewPdfFileName]);
            metaDataView = Identifier(); % metadata
            metaDataView.setValue([runManager.configuration.script_base_name '_data_view.xml']);
            dataViewIds = ArrayListMatlabWrapper;
            dataViewIds.add(dataViewId);
                 
            % YesWorkflow process view image (.pdf)
            processViewId = Identifier();
            processViewId.setValue(runManager.processViewPdfFileName); 
            processViewURI = URI([runManager.D1_CN_Resolve_Endpoint runManager.processViewPdfFileName]);
            metaProcessView = Identifier(); % metadata
            metaProcessView.setValue([runManager.configuration.script_base_name '_process_view.xml']);
            processViewIds = ArrayListMatlabWrapper;
            processViewIds.add(processViewId);
                 
            % Todo: wasDocumentedBy (because we do not have these science metadata in the package.)
            %runManager.dataPackage.insertRelationship(metaCombinedView, combinedViewIds);
            %runManager.dataPackage.insertRelationship(metaDataView, dataViewIds);
            %runManager.dataPackage.insertRelationship(metaProcessView, processViewIds);
                
            % wasGeneratedBy
            predicate = PROV.predicate('wasGeneratedBy');
            runManager.dataPackage.insertRelationship(combinedViewURI, predicate, runManager.execURI);  
            runManager.dataPackage.insertRelationship(dataViewURI, predicate, runManager.execURI);  
            runManager.dataPackage.insertRelationship(processViewURI, predicate, runManager.execURI);  
                
            % Record relationship identifying as provONE:Data              
            runManager.dataPackage.insertRelationship(combinedViewURI, runManager.aTypePredicate, runManager.provONEdataURI);
            runManager.dataPackage.insertRelationship(dataViewURI, runManager.aTypePredicate, runManager.provONEdataURI);
            runManager.dataPackage.insertRelationship(processViewURI, runManager.aTypePredicate, runManager.provONEdataURI);
                
            % Create D1Object for each figure and add the D1Object to the DataPackage
            imgFmt = 'application/pdf';      
            combinedViewFileId = File(combinedViewId.getValue());
            combinedViewData = FileDataSource(combinedViewFileId);
            combinedViewD1Obj = D1Object(combinedViewId, combinedViewData, D1TypeBuilder.buildFormatIdentifier(imgFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(combinedViewD1Obj);
             
            dataViewFileId = File(dataViewId.getValue());
            dataViewData = FileDataSource(dataViewFileId);
            dataViewD1Obj = D1Object(dataViewId, dataViewData, D1TypeBuilder.buildFormatIdentifier(imgFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(dataViewD1Obj);
                
            processViewFileId = File(processViewId.getValue());
            processViewData = FileDataSource(processViewFileId);
            processViewD1Obj = D1Object(processViewId, processViewData, D1TypeBuilder.buildFormatIdentifier(imgFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(processViewD1Obj);               
               
            metadataModelFactsId = Identifier;
            metadataModelFactsId.setValue([runManager.configuration.script_base_name  '_ywModelFacts.xml']);
            dataModelFactsIds = ArrayListMatlabWrapper;               
            modelFactsId = Identifier();
            modelFactsId.setValue(runManager.mfilename); % ywModelFacts prolog dump
            dataModelFactsIds.add(modelFactsId); 
            modelFactsURI = URI([runManager.D1_CN_Resolve_Endpoint runManager.mfilename]);
                
            % Create D1Object for ywModelFacts prolog dump and add the D1Object to the DataPackage
            prologDumpFmt = 'text/plain';      
            modelFactsFileId = File(modelFactsId.getValue());
            modelFactsData = FileDataSource(modelFactsFileId);
            modelFactsD1Obj = D1Object(modelFactsId, modelFactsData, D1TypeBuilder.buildFormatIdentifier(prologDumpFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(modelFactsD1Obj);
              
            metadataExtractFactsId = Identifier;
            metadataExtractFactsId.setValue([runManager.configuration.script_base_name  '_ywExtractFacts.xml']);
            dataExtractFactsIds = ArrayListMatlabWrapper;
            extractFactsId = Identifier;
            extractFactsId.setValue(runManager.efilename); % ywExtractFacts prolog dump
            dataExtractFactsIds.add(extractFactsId); 
            extractFactsURI = URI([runManager.D1_CN_Resolve_Endpoint runManager.efilename]);
                
            % Record wasDocumentedBy / wasGeneratedBy / provONE:Data relationships for ywModelFacts prolog and ywExtractFacts prolog dumps
            predicate = PROV.predicate('wasGeneratedBy');
            runManager.dataPackage.insertRelationship(modelFactsURI, predicate, runManager.execURI);  
            runManager.dataPackage.insertRelationship(extractFactsURI, predicate, runManager.execURI); 
            runManager.dataPackage.insertRelationship(modelFactsURI, runManager.aTypePredicate, runManager.provONEdataURI);
            runManager.dataPackage.insertRelationship(extractFactsURI, runManager.aTypePredicate, runManager.provONEdataURI);
            % Todo: because we do not have thse science metadata right now
            %runManager.dataPackage.insertRelationship(metadataExtractFactsId, dataExtractFactsIds);
            %runManager.dataPackage.insertRelationship(metadataModelFactsId, dataModelFactsIds); 
                                  
            % Create D1Object for ywExtractFacts prolog dump and add the D1Object to the DataPackage      
            extractFactsFileId = File(extractFactsId.getValue());
            extractFactsData = FileDataSource(extractFactsFileId);
            extractFactsD1Obj = D1Object(extractFactsId, extractFactsData, D1TypeBuilder.buildFormatIdentifier(prologDumpFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));
            runManager.dataPackage.addData(extractFactsD1Obj);
            
            % Serialize a datapackage
            rdfXml = runManager.dataPackage.serializePackage();
            if runManager.debug 
                fprintf('\nThe resource map is :\n %s \n\n', char(rdfXml)); % print it to stdout
            end
            
            % Print to a resourceMap 
            resMapName = ['resourceMap_' runManager.configuration.script_base_name '.rdf'];  
            fw = fopen(resMapName, 'w'); 
            if fw == -1, error('Cannot write "%s%".',resMapName); end
            fprintf(fw, '%s', char(rdfXml));
            fclose(fw);

            % Add resourceMap D1Object to the DataPackage                      
            resMapId = Identifier();
            resMapId.setValue(resMapName);
            resMapFmt = 'http://www.openarchives.org/ore/terms'; 
            resMapFileId = File(resMapId.getValue());
            resMapData = FileDataSource(resMapFileId);
            resMapD1Obj = D1Object(resMapId, resMapData, D1TypeBuilder.buildFormatIdentifier(resMapFmt), D1TypeBuilder.buildSubject(submitter), D1TypeBuilder.buildNodeReference(mnNodeId));          
            runManager.dataPackage.addData(resMapD1Obj);     
                    
        end
        
        
        function saveExecution(runManager, fileName)
            % SAVEEXECUTION saves the summary of each execution to an
            % execution database, a CSV file named execution.csv in the
            % provenance_storage_directory with the columns: runId,
            % filePath, startTime, endTime, publishedTime, packageId,
            % errorMessage.
            %   fileName - the name of the execution database
                     
            runID = char(runManager.runId);
            filePath = char(runManager.execution.software_application);
            startTime = char(runManager.execution.start_time);
            endTime = char(runManager.execution.end_time);
            publishedTime = char(runManager.execution.publish_time);
            packageId = char(runManager.execution.data_package_id);
            tag = num2str(unidrnd(100)); % generate a random integer
            errorMessage = char(runManager.execution.error_message);
     
            formatSpec = '%s, %s, %s, %s, %s, %s, %s, %s\n';
           
            curDir = pwd();
            cd(runManager.configuration.provenance_storage_directory);
            if exist(fileName, 'file') ~= 2
                [fileId, message] = fopen(fileName,'w');
                if fileId == -1
                    disp(message);
                end
                fprintf(fileId, formatSpec, 'runId', 'filePath', 'startTime', 'endTime', 'publishedTime', 'packageId', 'tag', 'errorMessage'); % write header
                fprintf(fileId,formatSpec, runID, filePath, startTime, endTime, publishedTime, packageId, tag, errorMessage); % write the metadata for the current execution
                fclose(fileId); 
            else
                [fileId, message] = fopen(fileName,'a');
                if fileId == -1
                    disp(message);
                end
                fprintf(fileId,formatSpec, runID, filePath, startTime, endTime, publishedTime, packageId, tag, errorMessage); % write the metadata for the current execution     
                fclose(fileId); 
            end
            cd(curDir);
        end
       
        
        function [execMetaMatrix, header] = getExecMetadataMatrix(runManager)
            % GETEXECMETADATAMATRIX returns a matrix storing the
            % metadata summary for all executions from the exeucton
            % database.
            %   runManager - 
            formatSpec = '%s %s %s %s %s %s %s %s\n';
            [fileId, message] = fopen(runManager.executionDatabaseName,'r');
            if fileId == -1
               disp(message); 
            else
                header = textscan(fileId, formatSpec, 1, 'Delimiter', ',');
                execMetaData = textscan(fileId,formatSpec,'Delimiter',',');
                fclose(fileId);
 
                % Convert a cell array to a matrix
                execMetaMatrix = [execMetaData{[1 2 3 4 5 6 7 8]}];
            end
        end
        
        
        function subjectHashSet = getSubjectsRelatedToProperty(runManager, filePath, p)
           % GETSUBJECTRELATEDTOPROPERTY get all related subjects related to a given property from all
           % triples contained in a resourcemap.
           %  filePath - the path to the resourcemap
           %  p - the given property of a RDF triple
           
           import org.dataone.ore.QueryResourceMap; % ! Need to add a new class in d1_libclient_java
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
           stmts = model.listStatements([], queryPredicate, QueryResourceMap.nullRDFNode); % null, (RDFNode)null
           subjectHashSet = HashSet();
           while (stmts.hasNext()) 
	            s = stmts.nextStatement();
	       	    t = s.asTriple();
	       	    subject = t.getSubject();
	    	    subjectName = subject.getLocalName();
                subjectHashSet.add(subjectName);
           end 
          
        end
        
        
        function u = union2Cells(runManager, m, n)
            % UNION2CELLS Merge two cell arrays by rows and remove
            % duplicate rows
            %   m -- cell array to be merged
            %   n -- cell array to be merged
            
            % Process data
            a = [n;m];          % All
            u = cell(size(a));  % Unique
     
            ku = 1;      % Unique counter
            u(ku,:) = a(1,:);   % Add first row

            % Add only rows that do not exist in u
            for ia = 2:size(a,1)
                found = false;   % search flag
                for iu = 1:ku
                    if all(strcmp(a(ia,:), u(iu,:)))
                            % row is already registered
                            found = true;
                            break;
                    end;
                end;
                if ~found
                    % add row
                    ku = ku+1;
                    u(ku,:) = a(ia,:);
                end;
            end;

            u = u(1:ku,:); % Trim unused space in u           
        end
        
    end
 
    
    methods (Static)
        function runManager = getInstance(configuration)
            % GETINSTANCE returns an instance of the RunManager by either
            % creating a new instance or returning an existing one.
                        
            import org.dataone.client.configure.Configuration;
           
            %% Set all jars under lib/java/ to the java dynamic class path (Need further consideration !)
            % RunManager.setJavaClassPath();
                       
            % Set the java class path
            RunManager.setMatlabPath();

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
    end
    
    methods    
        
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
                   
            % Do we have a script as input?
            if ( nargin < 2 )
                message = ['Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.'];
                error(message);
            end
            
            % Does the script exist?
            if ( ~exist(filePath, 'file'));
                error([' The script: '  filePath ' does not exist.' ...
                       'Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.']);                    
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
                    tagStr = cast(tag);
                end
                
            catch classCastException
                error(['The tag used for the record session cannot be ' ...
                       'cast to a string. Please use a tag label that is ' ...
                       ' a string or a data type that can be cast to ' ...
                       'a string. The error message was: ' ...
                       classCastException.message]);
                runManager.execution.error_message = [runManager.execution.error_message ' ' classCastException.message];
            end
            
            runManager.execution = Execution(tagStr);
            runManager.execution.software_application = filePath; % Set script path
            
            % Set up yesWorkflow and pass the path of a script to yesWorkflow
            runManager.configYesWorkflow(runManager.execution.software_application);
            
            % Begin recording
            runManager.startRecord(runManager.execution.tag);

            % End the recording session 
            data_package = runManager.endRecord();
        end
        
        
        function startRecord(runManager, tag)
            % STARTRECORD Starts recording provenance relationships (see record()).

            % Record the starting time when record() started 
            runManager.execution.start_time = datestr(now,30); % Use datestr to format the time and use now to get the current time          
            
            if ( runManager.recording )
                warning(['A RunManager session is already active. Please call ' ...
                         'endRecord() if you wish to close this session']);
                  
            end                
           
            % Compute script_base_name if it is not assigned a value
            if isempty(runManager.configuration.script_base_name)
                [pathstr,script_base_name,ext] = fileparts(runManager.execution.software_application);
                runManager.configuration.script_base_name = strtrim(script_base_name);      
            end
                        
            % Create the run metadata directory for this run
            position = strfind(runManager.execution.execution_id, 'urn:uuid:'); % get the index of 'urn:uuid:'            
            runManager.runId = runManager.execution.execution_id(position+9:end);
            runManager.runDir = strcat(runManager.configuration.provenance_storage_directory, filesep,'runs', filesep, runManager.runId);
            [status, message, message_id] = mkdir(runManager.runDir);         
            if ( status ~= 1 )
                error(message_id, [ 'The directory %s' ...
                    ' could not be created. The error message' ...
                    ' was: ' runManager.runDir, message]);
                runManager.execution.error_message = [runManager.execution.error_message ' ' message]; 
            end
            
            % Initialize a dataPackage to manage the run
            import org.dataone.client.v1.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;            
          
            packageIdentifier = Identifier();
            packageIdentifier.setValue(runManager.execution.data_package_id);            
            runManager.execution.data_package_id = packageIdentifier.getValue();
            
            % Create a resourceMap identifier
            resourceMapId = Identifier();
            resourceMapId.setValue(['resourceMap_' char(java.util.UUID.randomUUID())]);
            % Create an empty datapackage with resourceMapId
            runManager.dataPackage = DataPackage(resourceMapId);
                                      
            % Run the script and collect provenance information
          % runManager.prov_capture_enabled = true;
          % [pathstr, script_name, ext] = ...
          %     fileparts(runManager.execution.software_application);
          % addpath(pathstr);

          % try
          %     eval(script_name);             
          % catch runtimeError
          %     error(['The script: ' ...
          %            runManager.execution.software_application ...
          %            ' could not be run. The error message was: ' ...
          %             runtimeError.message]);                
          % end
          
        end
        
        
        function data_package = endRecord(runManager)
            % ENDRECORD Ends the recording of an execution (run).
            
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.client.v1.itk.D1Object;
            import org.dataone.client.v1.itk.DataPackage;
            import org.dataone.client.run.NamedConstant;
            import java.io.File;
            import javax.activation.FileDataSource;
            import org.dataone.client.v1.types.D1TypeBuilder;
            import org.dataone.vocabulary.PROV;
            import org.dataone.vocabulary.ProvONE;
            import java.net.URI;
            import org.dataone.client.v1.itk.ArrayListMatlabWrapper;
            
            % Stop recording
            runManager.recording = false;
            runManager.prov_capture_enabled = false;
               
            % Get submitter and MN node reference
            submitter = runManager.execution.account_name;
            mnNodeId = runManager.configuration.target_member_node_id;
                     
            % Generate yesWorkflow image outputs
            if runManager.configuration.generate_workflow_graphic
                % Call yesWorkflow to capture prospective provenance for current scirpt
                curDir = pwd();
                runManager.captureProspectiveProvenanceWithYW();
            end
            
            % Include yesWorkflow graphics
            if runManager.configuration.include_workflow_graphic 
                cd(runManager.runDir);
                runManager.generateYesWorkflowGraphic();
                cd(curDir);
            end    
        
            % Build a D1 datapackage
            cd(runManager.runDir);
            runManager.buildPackage(submitter, mnNodeId);              
            cd(curDir);
            
            % Return the Java DataPackage as a Matlab structured array
            data_package = struct(runManager.dataPackage);        
                
            % Unlock the RunManager instance
            munlock('RunManager');
            
            % Record the ending time when record() ended using format 30 (ISO 8601)'yyyymmddTHHMMSS'             
            runManager.execution.end_time = datestr(now,30);
            
            % Save the metadata for the current execution
            runManager.saveExecution(runManager.executionDatabaseName);                      
        end
        
        
        function runs = listRuns(runManager, quiet, startDate, endDate, tags)
            % LISTRUNS Lists prior executions (runs) and information about them from executions metadata database.
            %   quiet -- control the output or not
            %   startDate -- the starting timestamp for an execution
            %   endDate -- the ending timestamp for an execution
            %   tag -- a tag given to an execution 
            
            curDir = pwd();
            cd(runManager.configuration.provenance_storage_directory);
                                 
            % Read the exeuction metadata summary from the exeuction
            % metadata database
            [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
           
            % Initialize the logical cell arrays for the next call for listRuns()
            dateCondition = false(size(execMetaMatrix, 1), 1);
            tagsCondition = false(size(execMetaMatrix, 1), 1);
            allCondition = false(size(execMetaMatrix, 1), 1);
            
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
                startCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') > startDateNum;
                endColCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') < endDateNum;
                dateCondition = startCondition & endColCondition;
            elseif startDateFlag == 1
                startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                % Extract multiple rows from a matrix 
                dateCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') > startDateNum; % Column 3 for startDate
            elseif endDateFlag == 1
                endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');
                dateCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') < endDateNum; % Column 4 for endDate
            else % No query parameters are required 
                dateCondition = false(size(execMetaMatrix, 1), 1);
            end
                        
            % Process the query parameter "tags" 
            if ~isempty(tags)
                tagsArray = char(tags);
                tagsCondition = ismember(execMetaMatrix(:,7), tagsArray); % compare the existence between two arrays (column 7 for tag)
                %tagsCondition
                allCondition = dateCondition | tagsCondition; % Logical OR operator
            else
                allCondition = dateCondition;
            end
            
            %allCondition
            
            % Extract multiple rows from a matrix 
            runs = execMetaMatrix(allCondition, :);
            
            if isempty(quiet) ~= 1 && quiet ~= 1
                % Convert a cell array to a table with headers                 
                tableForSelectedRuns = cell2table(runs,'VariableNames', [header{:}]);  
                disp(tableForSelectedRuns);                      
            end
           
            cd(curDir);           
        end
        
        
        function deleted_runs = deleteRuns(runManager, runIdList, startDate, endDate, tags, noop, quiet)
            % DELETERUNS Deletes prior executions (runs) from the stored
            % list.    
            
            curDir = pwd();
            cd(runManager.configuration.provenance_storage_directory);
            % Read the exeuction metadata summary from the exeuction metadata database
            [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
           
            size(execMetaMatrix)
            
            % Initialize the logical cell arrays to have false value
            dateCondition = false(size(execMetaMatrix, 1), 1);
            runIdCondition = false(size(execMetaMatrix, 1), 1);
            tagsCondition = false(size(execMetaMatrix, 1), 1);
            allDeleteCondition = false(size(execMetaMatrix, 1), 1);
            
            % Step 1: find all runs to be deleted using the query parameter: runIdList
            deleted_runs_1 = [];
            runIdCondition = [];
            if ~isempty(runIdList) 
                runIdArray = char(runIdList);
                runIdCondition = ismember(execMetaMatrix(:,1), runIdArray); % compare the existence between two arrays 
                deleted_runs_1 = execMetaMatrix(runIdCondition, :);
                size(deleted_runs_1)
            end
            
            % Step 2: find all runs to be deleted using the query parameters: startDate, endDate and tags
            cd(curDir);
            deleted_runs_2 = runManager.listRuns(quiet, startDate, endDate, tags);
            size(deleted_runs_2)
            
            % Step 3: merge the two selected runs cell array into a larger cell
            % array and duplicate rows are removed.
            if ~isempty(deleted_runs_1) && ~isempty(deleted_runs_2)
                deleted_runs = runManager.union2Cells(deleted_runs_1, deleted_runs_2);
                %size(deleted_runs)
            elseif ~isempty(deleted_runs_1)
                deleted_runs = deleted_runs_1;
            else
                deleted_runs = deleted_runs_2;
            end
      
            % Delete the selected runs from the execution matrix and update the exeucution database
            if noop == 1
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
            
                % Loop through the selectedIdSet cell
                runsDir = fullfile(curDir, filesep, runManager.configuration.provenance_storage_directory, filesep, 'runs', filesep);
                cd(runsDir); % go to the runs/ direcotry
                
                % Delete the selected runs
                for k = 1:length(selectedIdSet)                   
                    selectedRunDir = fullfile(selectedIdSet{k}, filesep);
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
                    startCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') > startDateNum;
                    endColCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') < endDateNum;
                    dateCondition = startCondition & endColCondition;
                elseif startDateFlag == 1
                    startDateNum = datenum(startDate,'yyyymmddTHHMMSS');
                    dateCondition = datenum(execMetaMatrix(:,3),'yyyymmddTHHMMSS') > startDateNum; % logical vector for rows to delete                
                elseif endDateFlag == 1
                    endDateNum = datenum(endDate, 'yyyymmddTHHMMSS');
                    dateCondition = datenum(execMetaMatrix(:,4),'yyyymmddTHHMMSS') < endDateNum;                   
                else % No query parameters are required, then dateCondition is set to be false
                    dateCondition = false(size(execMetaMatrix, 1), 1);
                end
                        
                if ~isempty(runIdList)
                    allDeleteCondition = dateCondition | runIdCondition;
                else
                    allDeleteCondition = dateCondition;
                end
                
                if ~isempty(tags)
                    tagsArray = char(tags);
                    tagsCondition = ismember(execMetaMatrix(:,7), tagsArray); % compare the existence between two arrays (column 7 for tag)
                    allDeleteCondition = allDeleteCondition | tagsCondition;
                end
                
                execMetaMatrix(allDeleteCondition, :) = []; % deleted the selected rows
                size(execMetaMatrix)
                    
                cd(curDir);
                cd(runManager.configuration.provenance_storage_directory);
                    
                % Write the updated execution metadata with headers to the execution database
                T = cell2table(execMetaMatrix,'VariableNames',[header{:}]);
                writetable(T, runManager.executionDatabaseName);                  
                             
                cd(curDir);
          
            end
            
        end
        
        
        function package_id = view(runManager, packageId)
           % VIEW Displays detailed information about a data package that
           % is the result of an execution (run).
 
           % Display a warning message to the user
           disp('Warning: There is no scientific metadata in this data package.');
           % Select runs based on the packageID. Report ?No runs can be found as a match? 
           % and returns if no runs are matched, 
           if(isempty(packageId) ~= 1)
               curDir = pwd();
               cd(runManager.configuration.provenance_storage_directory);
            
               % Read the exeuction metadata summary from the exeuction
               % metadata database
               [execMetaMatrix, header] = runManager.getExecMetadataMatrix();
               pkgIdCondition = strcmp(execMetaMatrix(:,6), packageId); % Column 6 in the execution matrix for packageId
               selectedRuns = execMetaMatrix(pkgIdCondition, :);
               if isempty(selectedRuns)
                   error('No runs can be found as a match.');
               end
                   
               % Get the runId from the selectedRuns
               % Todo: need to check if the number of rows of selectedRunId is 1 or not?
               selectedRunId = selectedRuns{1,1}; 
             
           else
               error('Missing the packageId parameter.');
           end
           
           import org.dataone.ore.QueryResourceMap; % ! Need to add a new class in d1_libclient_java
           import org.dataone.vocabulary.PROV;
           import org.dspace.foresite.Predicate;
           import com.hp.hpl.jena.rdf.model.Property;
           import com.hp.hpl.jena.rdf.model.RDFNode;
           import java.util.Iterator;
           
           % Go to the runs/ directory
           selectedRunDir = fullfile(curDir, filesep, runManager.configuration.provenance_storage_directory, filesep, 'runs', selectedRunId, filesep);
           cd(selectedRunDir);

           resMapFileName = strtrim(ls('*.rdf')); % list the reosurceMap.rdf and remove the whitespace and return characters  
           wasGeneratedByPredicate = PROV.predicate('wasGeneratedBy');
           % Call Java getSubjectsRelatedToProperty() method (Way 1)
           subjectNameSet = QueryResourceMap.getSubjectsRelatedToProperty(resMapFileName, wasGeneratedByPredicate); 
           
           % Call Matlab getSubjectRelatedToProperty() method (Way 2)
           % subjectNameSet = runManager.getSubjectsRelatedToProperty(resMapFileName, wasGeneratedByPredicate);
      
           % Create a struct for created files during the current run
           subjectNameArray = subjectNameSet.toArray(); % convert a java set instance to an array instance
           for i = 1:subjectNameSet.size()
                createdFileNameStruct(i,1).FileName = char(subjectNameArray(i));
           end

           % Deserialize the datapackage
           import org.dataone.client.v1.itk.DataPackage;
           import java.nio.file.Files;
           import java.nio.file.Path;
           import java.nio.file.Paths;
           import java.lang.String;
          
           % Warning: this call works but the returned identifiers is an
           % empty set. So I use the runManager.dataPackage instead.
           % resMapData = String(Files.readAllBytes(Paths.get(selectedRunDir, resMapFileName)));  % Read resourceMap into a string using Java 7 API
           % dataPkg = DataPackage.deserializePackage(resMapData);
           % identifierList = dataPkg.identifiers(); % Get all the identifiers in the datapackage
           % fprintf('pkgID: %s\n', char(dataPkg.getPackageId().getValue()));
           
           identifierList = runManager.dataPackage.identifiers();   
           identifierArray = identifierList.toArray(); % convert a java set instance to an array instance
           for i = 1:identifierList.size()
               aIdentifier = identifierArray(i);
               d1Obj = runManager.dataPackage.get(aIdentifier);
               d1ObjSysMeta = d1Obj.getSystemMetadata();
               d1ObjName = d1Obj.getIdentifier().getValue();
               d1ObjFileSize = d1ObjSysMeta.getSize().longValue();
               d1ObjMetaModifiedTime = d1ObjSysMeta.getDateSysMetadataModified();
               
               % Create a table for files to be published in a datapackage
               publishFileStruct(i,1).FileName = char(d1ObjName);
               publishFileStruct(i,1).FileSize = d1ObjFileSize;
               publishFileStruct(i,1).SysMetaModifiedTime = char(d1ObjMetaModifiedTime.toGMTString()); % Todo: find the file modified date
              
           end
          
           fprintf('\n***********************************************************************************************************************\n');
           fprintf('Package identifer: %s\n', char(packageId));
           fprintf('This package was created by run: %s\n\n', selectedRunId);
           
           fprintf('Files created from this run:\n\n');
           TableForFileCreated = struct2table(createdFileNameStruct); % Convert a struct to a table
           disp(TableForFileCreated);
                  
           fprintf('Local data files used: (N/A)');
           %Todo: local data files
           
           fprintf('\n\nDataPackage to be published to DataONE\n');
           fprintf('======================================\n');
           %Todo: provenance 
           
           TableForFile2Published = struct2table(publishFileStruct); % Convert a struct to a table
           disp(TableForFile2Published);
           
           fprintf('\n**********************************************************************************************************************\n');
                      
           package_id = packageId;
           cd(curDir);
        end
  
        
        function package_id = publish(runManager, packageId)
            % PUBLISH Uploads a data package produced by an execution (run)
            % to the configured DataONE Member Node server.
            
            import java.lang.String;
            import java.lang.Boolean;
            import java.lang.Integer;
            import org.dataone.client.v1.MNode;
            %import org.dataone.client.v2.impl.MultipartMNode;
            %import org.dataone.client.v2.impl.MultipartCNode;
            import org.dataone.client.v1.itk.D1Client;
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.v1.itk.DataPackage;           
            import org.dataone.service.types.v1.SystemMetadata;
            import org.dataone.service.types.v1.Session;
            import org.dataone.service.util.TypeMarshaller;
            import org.dataone.service.types.v1.AccessPolicy;
            import org.dataone.service.types.v1.util.AccessUtil;
            import org.dataone.service.types.v1.Permission;            
            import org.dataone.service.types.v1.ReplicationPolicy;
            import org.dataone.service.types.v1.Subject;
           
            curDir = pwd();
            
            curRunDir = [runManager.runDir filesep packageId filesep];
            fprintf('curRunDir: %s\n', curRunDir);
            if ~exist(curRunDir, 'dir')
                error([' A directory was not found for execution identifier: ' packageId]);       
            end       
            
            cd(curRunDir); % go the the selected run directory
            
            % Get a MNode instance to the Member Node
            try 
                % Get D1 cilogon certificate stored at /tmp/x509up_u501
                certificate = runManager.getCertificate();
                % Pull the subject DN out of the certificate for use in system metadata
                runManager.configuration.submitter = certificate.getSubjectDN().toString();
               
                % Set the MNode ID
                mnRef = NodeReference();
                mnRef.setValue(runManager.configuration.target_member_node_id);            
                % Get a MNode instance to the Member Node using the Node ID
                mnNode = D1Client.getMN(mnRef);
                if isempty(mnNode)
                   error(['Member node' runManager.configuration.target_member_node_id 'encounted an error on the getMN() request.']); 
                end
                    
                fprintf('mn ndoe base url is: %s\n', char(mnNode.getNodeBaseServiceUrl()));               
                fprintf('dataPackage.size()= %d\n',runManager.dataPackage.size());
                            
                % Set the CNode ID
                cnRef = NodeReference();
                cnRef.setValue(runManager.CN_URL);
                cnNode = D1Client.getCN(cnRef.getValue());
                if isempty(cnNode)
                   error(['Coordinatior node' runManager.D1_CN_Resolve_Endpoint 'encounted an error on the getCN() request.']); 
                end
                
                submitter = Subject();
                submitter.setValue(runManager.configuration.submitter);
                    
                session = Session();
            
                % Upload each data object that was added to the datapackage
                dataObjIdentifiers = runManager.dataPackage.identifiers();
                iter = dataObjIdentifiers.iterator();
                while iter.hasNext()
                    dataObjId = iter.next();
                    fprintf('Uploading id: %s\n', char(dataObjId.getValue()));
                    
                    % get the DataSource representing the data for the dataObjId
                    dataObj = runManager.dataPackage.get(dataObjId);
                    dataSource = dataObj.getDataSource();
                    
                    % get system metadata for dataObj and convert v1 systemetadata to v2 systemmetadata
                    v1SysMeta = dataObj.getSystemMetadata(); % version 1 system metadata
                     
                    if runManager.debug
                        fprintf('***********************************************************\n');
                        fprintf('d1Obj.size=%d (bytes)\n', v1SysMeta.getSize().longValue());                   
                        fprintf('d1Obj.checkSum algorithm is %s and the value is %s\n', char(v1SysMeta.getChecksum().getAlgorithm()), char(v1SysMeta.getChecksum().getValue()));
                        fprintf('d1Obj.rightHolder=%s\n', char(v1SysMeta.getRightsHolder().getValue()));
                        fprintf('d1Obj.sysMetaModifiedDate=%s\n', char(v1SysMeta.getDateSysMetadataModified().toString()));
                        fprintf('d1Obj.dateUploaded=%s\n', char(v1SysMeta.getDateUploaded().toString()));
                        fprintf('d1Obj.originalMNode=%s\n', char(v1SysMeta.getOriginMemberNode().getValue()));
                        fprintf('***********************************************************\n');
                    end
                    
                    % set the other information for sysmeta (submitter, rightsHolder, foaf_name, AccessPolicy, ReplicationPolicy)                                    
                    v1SysMeta.setSubmitter(submitter);
                    v1SysMeta.setRightsHolder(submitter);
                    
                    if runManager.configuration.public_read_allowed == 1
                        strArray = javaArray('java.lang.String', 1);
                        permsArrary = javaArray('org.dataone.service.types.v1.Permission', 1);
                        strArray(1,1) = String('public');
                        permsArray(1,1) = Permission.READ;
                        ap = AccessUtil.createSingleRuleAccessPolicy(strArray, permsArray);
                        v1SysMeta.setAccessPolicy(ap);
                        fprintf('d1Obj.accessPolicySize=%d\n', v1SysMeta.getAccessPolicy().sizeAllowList());
                    end                   
                                    
                    if runManager.configuration.replication_allowed == 1
                        rp = ReplicationPolicy();
                        numReplicasStr = String.valueOf(int32(runManager.configuration.number_of_replicas));
                        rp.setNumberReplicas(Integer(numReplicasStr));                       
                        rp.setReplicationAllowed(java.lang.Boolean.TRUE);                      
                        v1SysMeta.setReplicationPolicy(rp);                                               
                        fprintf('d1Obj.numReplicas=%d\n', v1SysMeta.getReplicationPolicy().getNumberReplicas().intValue());                     
                    end
                    
                    % Upload the data to the MN using create(), checking for success and a returned identifier       
                    pid = cnNode.reserveIdentifier(session,v1SysMeta.getIdentifier()); 
                    if isempty(pid) ~= 1
                        returnPid = mnNode.create(session, pid, dataSource.getInputStream(), v1SysMeta);  
                        if isempty(returnPid) ~= 1
                            fprintf('Success uploaded %s\n.', char(returnPid.getValue()));
                        else
                            % TODO: Process the error correctly.
                            error('Error on returned identifier %s', char(v1SysMeta.getIdentifier()));
                        end
                    else
                        % TODO: Process the error correctly.
                        error('Error on duplicate identifier %s', v1SysMeta.getIdentifier());
                    end
                end
                
                cd(curDir);
                package_id = packageId; % temporary
         
            catch runtimeError 
                error(['Could not create member node reference: ' runtimeError.message]);
                runManager.execution.error_message = [runManager.execution.error_message ' ' runtimeError.message];
            end
            
            % Record the date and time that the package from this run is uploaded to DataONE
            runManager.execution.publish_time = save(datestr(now,30));
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
            end
        end
        
    end

end

