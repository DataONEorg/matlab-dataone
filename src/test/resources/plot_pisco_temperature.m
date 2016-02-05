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
c.target_member_node_id = 'urn:node:KNB';
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



