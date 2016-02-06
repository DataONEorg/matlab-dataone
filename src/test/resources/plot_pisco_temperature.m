import org.dataone.client.v2.DataONEClient;
import org.dataone.client.configure.Configuration;

% Keep track of directories, and write to the default userpath
current_dir = pwd;
path = strsplit(userpath, ':');
userdir = char(path{1});
cd(userdir);

% Configure the nodes to connect to
c = Configuration.loadConfig('');
saved_coordinating_node_base_url = c.coordinating_node_base_url;
c.coordinating_node_base_url = 'https://cn.dataone.org/cn';
c.source_member_node_id = 'urn:node:KNB';
c.target_member_node_id = 'urn:node:mnSandboxUCSB1';

% Set the science metadata configuration fields
c.science_metadata_config.title_prefix = 'PISCO: Intertidal temperature processing: ';
c.science_metadata_config.title_suffix = '';
c.science_metadata_config.primary_creator_salutation = 'Dr.';
c.science_metadata_config.primary_creator_givenname = 'Carol';
c.science_metadata_config.primary_creator_surname = 'Blanchette';
c.science_metadata_config.primary_creator_address1 = 'Marine Science Institute';
c.science_metadata_config.primary_creator_address2 = 'University of California Santa Barbara';
c.science_metadata_config.primary_creator_city = 'Santa Barbara';
c.science_metadata_config.primary_creator_state = 'CA';
c.science_metadata_config.primary_creator_zipcode = '93101';
c.science_metadata_config.primary_creator_country = 'USA';
c.science_metadata_config.primary_creator_email = 'blanchette@msi.ucsb.edu';
c.science_metadata_config.language = 'English';
c.science_metadata_config.abstract = ...
    ['This metadata record describes moored seawater ' ...
     'temperature data collected at Jalama Beach ' ...
     'Campground, California, USA, by PISCO.  ' ...
     'Measurements were collected using StowAway ' ...
     'Tidbit Temperature Loggers (Onset Computer ' ...
     'Corp. TBIC32+4+27) beginning 2000-05-23.  ' ...
     'The instrument depth was 003 meters, in an ' ...
     'overall water depth of 015 meters (both ' ...
     'relative to Mean Sea Level, MSL).  ' ...
     'The sampling interval was 2.0 minutes. ']; ...
c.science_metadata_config.keyword1 = 'intertidal';
c.science_metadata_config.keyword2 = 'temperature';
c.science_metadata_config.keyword3 = 'Santa Cruz Island';
c.science_metadata_config.keyword4 = 'California';
c.science_metadata_config.keyword5 = 'global';
c.science_metadata_config.intellectual_rights = ...
    ['Please cite PISCO in all publications containing these data.   ' ...
    'The citation should take the form: "This study utilized data    ' ...
    'collected by the Partnership for Interdisciplinary Studies of   ' ...
    'Coastal Oceans: a long-term ecological consortium funded by the ' ...
    'David and Lucile Packard Foundation and the Gordon and Betty    ' ...
    'Moore Foundation."'];

c.saveConfig();

% Get a Member Node to talk to
mn = DataONEClient.getMN('urn:node:KNB');

% Get a known temperature dataset
data = char(mn.get([], 'doi:10.6085/AA/JALXXX_015MTBD003R00_20000523.40.2')');

% Parse it
data_cell_array = textscan(data, '%s%s%s%s%s', ...
    'Delimiter', ' ', ...
    'HeaderLines', 1);

% Extract the dates and temperatures
data_lines = strsplit(data, '\n');
column_names = strsplit(char(data_lines{1}), ' ');
clear data_lines;

dates = datetime( ...
    [char(data_cell_array{1}) char(data_cell_array{2})], ...
    'TimeZone', 'UTC', ...
    'InputFormat', 'yyyy-MM-ddHH:mm:ss.SSZ');

temps = str2num(char(data_cell_array{4}));

% Plot the temperature figure
temps_figure = figure;
set(temps_figure, 'Position', [0 0 1080 720]);
plot(dates, temps);
title( ...
    ['Intertidal Temperatures in May/June 2000, ' ...
    'Jalama, Santa Cruz Island, California'], ...
    'FontSize', 18);

temps_axes = gca;
temps_axes.XLabel.String = 'Date';
temps_axes.YLabel.String = '\circC';
temps_axes.YGrid = 'on';

% Export the figure
frame = getframe(temps_figure);
temps_image = frame2im(frame);
imwrite(temps_image, 'JALXXX_015MTBD003R00_20000523.40.2.png');
% print(temps_figure, 'JALXXX_015MTBD003R00_20000523.40.2.png', '-dpng');

% Clean up
cd(current_dir);
c.coordinating_node_base_url = saved_coordinating_node_base_url;
c.saveConfig();



