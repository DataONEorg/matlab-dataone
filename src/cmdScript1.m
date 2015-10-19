%addpath(genpath('/Users/syc/Documents/matlab-dataone'));

import org.dataone.client.run.RunManager;
import org.dataone.client.configure.Configuration;

mgr = RunManager.getInstance();

filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';

script_path = which(filename);

tag = 'c3_c4_na_1';

% mgr.PROCESS_VIEW_PROPERTY_FILE_NAME = '/Users/syc/Documents/matlab-dataone/lib/yesworkflow/yw_process_view.properties'; 

% mgr.DATA_VIEW_PROPERTY_FILE_NAME = '/Users/syc/Documents/matlab-dataone/lib/yesworkflow/yw_data_view.properties';

% mgr.COMBINED_VIEW_PROPERTY_FILE_NAME = '/Users/syc/Documents/matlab-dataone/lib/yesworkflow/yw_comb_view.properties'; 

cd('src/test/resources');

mgr.record(script_path, tag); 

