classdef NamedConstant
   properties (Constant = true)
       % Define constants from the Prov Ontology (http://www.w3.org/TR/prov-dm)
        RDF_NS = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
        rdfType = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type';
        provNS = 'http://www.w3.org/ns/prov#';
        provQualifiedAssociation = 'http://www.w3.org/ns/prov#qualifiedAssociation';
        provWasDerivedFrom = 'http://www.w3.org/ns/prov#wasDerivedFrom';
        provHadPlan = 'http://www.w3.org/ns/prov#hadPlan';
        provUsed = 'http://www.w3.org/ns/prov#used';
        provWasGeneratedBy = 'http://www.w3.org/ns/prov#wasGeneratedBy';
        provAssociation = 'http://www.w3.org/ns/prov#Association';
        provWasAssociatedWith = 'http://www.w3.org/ns/prov#wasAssociatedWith';
        provAgent = 'http://www.w3.org/ns/prov#Agent';
            
        % Define constants from the ProvONE Ontology 
        provONE_NS = 'http://purl.org/provone/2015/15/ontology#';
        provONEprogram = 'http://purl.org/provone/2015/15/ontology#Program';
        provONEexecution = 'http://purl.org/provone/2015/15/ontology#Execution';
        provONEdata = 'http://purl.org/provone/2015/15/ontology#Data';
        provONEuser = 'http://purl.org/provone/2015/15/ontology#User';
            
        % Define XML schema
        xsdString = 'http://www.w3.org/2001/XMLSchema#string';
            
        % Define constants from Open Archives Initiative Obect Reuse and Exchange
        OREterms_URI = 'http://www.openarchives.org/ore/terms';
        
        % Define cito ontology
        cito_NS = 'http://purl.org/spar/cito/'; % should I use cito_NS or cito_URI?
        
        % Define member node url
        cnBaseURL = 'https://cn-sandbox-2.test.dataone.org/cn/v1/resolve/';
   end
end