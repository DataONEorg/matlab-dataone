docNode = com.mathworks.xml.XMLUtils.createDocument('Familie'); 
docRootNode = docNode.getDocumentElement; 

% 
% left side of tree 
% 

grandParentsElement = docNode.createElement('Grosseltern_1'); 
docRootNode.appendChild(grandParentsElement); 

parentsElement = docNode.createElement('Onkel_und_Tante_1'); 
grandParentsElement.appendChild(parentsElement); 

childElement = docNode.createElement('Cousin_1'); 
parentsElement.appendChild(childElement); 

childElement = docNode.createElement('Cousin_2'); 
childElement.appendChild(docNode.createTextNode(sprintf('Der Da'))); 
parentsElement.appendChild(childElement); 

parentsElement = docNode.createElement('Vater'); 
grandParentsElement.appendChild(parentsElement); 

childElement = docNode.createElement('Bruder'); 
parentsElement.appendChild(childElement); 

% 
% right side of tree 
% 

grandParentsElement = docNode.createElement('Grosseltern_2'); 
docRootNode.appendChild(grandParentsElement); 

parentsElement = docNode.createElement('Mutter'); 
grandParentsElement.appendChild(parentsElement); 

childElement = docNode.createElement('Schwester'); 
parentsElement.appendChild(childElement); 

parentsElement = docNode.createElement('Onkel_und_Tante_2'); 
grandParentsElement.appendChild(parentsElement); 

childElement = docNode.createElement('Cousin_3'); 
parentsElement.appendChild(childElement); 

childElement = docNode.createElement('Cousin_4'); 
parentsElement.appendChild(childElement); 

parentsElement = docNode.createElement('Onkel_und_Tante_3'); 
grandParentsElement.appendChild(parentsElement); 

childElement = docNode.createElement('Cousin_5'); 
parentsElement.appendChild(childElement); 

childElement = docNode.createElement('Cousin_6'); 
parentsElement.appendChild(childElement); 

childElement = docNode.createElement('Cousin_7'); 
parentsElement.appendChild(childElement); 

xmlFileName = [tempname, '.xml']; 
% Write XML-File with filename given by xmlFileName, docNode = Root Element as 
% highest ranking node 
xmlwrite(xmlFileName, docNode); 
% edit(xmlFileName); 

fclose('all');
delete(xmlFileName); 