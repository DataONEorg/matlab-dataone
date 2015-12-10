xDoc = xmlread(fullfile(matlabroot,'toolbox/matlab/general/info.xml'));
xRoot = xDoc.getDocumentElement;
schemaURL = char(xRoot.getAttribute('xsi:noNamespaceSchemaLocation'))
