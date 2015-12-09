% This test script can be used to test the MNode.get() method of the MNode
% class. This script downloads a dataset from DataONE and creates a local
% csv file from this dataset.
% The provenance relationships that should be recorded are:
% testData.csv <-- wasGeneratedBy <-- sampleUserScript.R
% sampleUserScript.R <-- used <--
% doi:10.6085/AA/pisco_intertidal_summar.42.3
%

disp('Sample User Script');

% Set the certificate/token in order to call services at d1 mn node
% cm = CertificateMaanger();
% getCertExpires(cm);

import org.dataone.client.v2.D1Client;
import org.dataone.client.v2.MNode;

% mnNode = D1Client('SANDBOX', 'urn:node:mnSandboxUCSB1');
mn_base_url = 'urn:node:mnSandboxUCSB1';
matlab_mn_node = MNode(mn_base_url);
matlab_mn_node.setMN(matlab_mn_node);

% Download a single D1 object
% item = getD1Object(cli, 'doi:10.6085/AA/pisco_intertidal_summary.42.3');
item = matlab_mn_node.get([], 'doi:10.6085/AA/pisco_intertidal_summary.42.3'); % Is it ok that a pid is an instance of doi?

% Pull out data as a data frame
% df = asDataFrame(item);
df = csvread(item);

% Save local file
% write.csv(df, file='testData.csv');
csvwrite('testData.csv', df);
