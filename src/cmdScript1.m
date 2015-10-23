%addpath(genpath('/Users/syc/Documents/matlab-dataone'));

import org.dataone.client.run.RunManager;
import org.dataone.client.configure.Configuration;

mgr = RunManager.getInstance();

filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';

script_path = which(filename);

tag = 'c3_c4_na_1';

cd('src/test/resources');

mgr.record(script_path, tag); 

mgr.listRuns();

mgr.view('runNumber', 1);

mgr.view('runNumber', 1, 'sessions', {'details', 'used', 'generated'});