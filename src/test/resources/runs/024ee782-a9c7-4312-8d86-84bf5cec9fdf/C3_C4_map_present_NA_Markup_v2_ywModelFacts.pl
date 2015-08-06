
% FACT: program(program_id, program_name, qualified_program_name, begin_annotation_id, end_annotation_id).
program(1, 'main', 'main', 1, 79).
program(2, 'fetch_SYNMAP_land_cover_map_variable', 'main.fetch_SYNMAP_land_cover_map_variable', 14, 25).
program(3, 'fetch_monthly_mean_air_temperature_data', 'main.fetch_monthly_mean_air_temperature_data', 26, 31).
program(4, 'fetch_monthly_mean_precipitation_data', 'main.fetch_monthly_mean_precipitation_data', 32, 37).
program(5, 'initialize_Grass_Matrix', 'main.initialize_Grass_Matrix', 38, 41).
program(6, 'examine_pixels_for_grass', 'main.examine_pixels_for_grass', 42, 51).
program(7, 'generate_netcdf_file_for_C3_fraction', 'main.generate_netcdf_file_for_C3_fraction', 52, 60).
program(8, 'generate_netcdf_file_for_C4_fraction', 'main.generate_netcdf_file_for_C4_fraction', 61, 69).
program(9, 'generate_netcdf_file_for_Grass_fraction', 'main.generate_netcdf_file_for_Grass_fraction', 70, 78).

% FACT: workflow(program_id).
workflow(1).

% FACT: function(program_id).

% FACT: has_subprogram(program_id, subprogram_id).
has_subprogram(1, 2).
has_subprogram(1, 3).
has_subprogram(1, 4).
has_subprogram(1, 5).
has_subprogram(1, 6).
has_subprogram(1, 7).
has_subprogram(1, 8).
has_subprogram(1, 9).

% FACT: port(port_id, port_type, port_name, qualified_port_name, port_annotation_id, data_id).
port(39, 'in', 'mstmip_SYNMAP_NA_QD.nc', 'main<-mstmip_SYNMAP_NA_QD.nc', 2, 22).
port(40, 'in', 'mean_airtemp', 'main<-mean_airtemp', 4, 23).
port(41, 'in', 'mean_precip', 'main<-mean_precip', 6, 24).
port(42, 'out', 'C3_fraction_data', 'main->C3_fraction_data', 8, 25).
port(43, 'out', 'C4_fraction_data', 'main->C4_fraction_data', 10, 26).
port(44, 'out', 'Grass_fraction_data', 'main->Grass_fraction_data', 12, 27).
port(45, 'in', 'mstmip_SYNMAP_NA_QD.nc', 'main.fetch_SYNMAP_land_cover_map_variable<-mstmip_SYNMAP_NA_QD.nc', 15, 28).
port(46, 'out', 'lon', 'main.fetch_SYNMAP_land_cover_map_variable->lon', 17, 29).
port(47, 'out', 'lat', 'main.fetch_SYNMAP_land_cover_map_variable->lat', 19, 30).
port(48, 'out', 'lon_bnds', 'main.fetch_SYNMAP_land_cover_map_variable->lon_bnds', 21, 31).
port(49, 'out', 'lat_bnds', 'main.fetch_SYNMAP_land_cover_map_variable->lat_bnds', 23, 32).
port(50, 'in', 'mean_airtemp', 'main.fetch_monthly_mean_air_temperature_data<-mean_airtemp', 27, 33).
port(51, 'out', 'Tair', 'main.fetch_monthly_mean_air_temperature_data->Tair', 29, 34).
port(52, 'in', 'mean_precip', 'main.fetch_monthly_mean_precipitation_data<-mean_precip', 33, 35).
port(53, 'out', 'Rain', 'main.fetch_monthly_mean_precipitation_data->Rain', 35, 36).
port(54, 'out', 'Grass', 'main.initialize_Grass_Matrix->Grass', 39, 37).
port(55, 'in', 'Tair', 'main.examine_pixels_for_grass<-Tair', 43, 34).
port(56, 'in', 'Rain', 'main.examine_pixels_for_grass<-Rain', 45, 36).
port(57, 'out', 'C3', 'main.examine_pixels_for_grass->C3', 47, 38).
port(58, 'out', 'C4', 'main.examine_pixels_for_grass->C4', 49, 39).
port(59, 'in', 'lon_variable', 'main.generate_netcdf_file_for_C3_fraction<-lon_variable', 53, 29).
port(60, 'in', 'lat_variable', 'main.generate_netcdf_file_for_C3_fraction<-lat_variable', 54, 30).
port(61, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_C3_fraction<-lon_bnds_variable', 55, 31).
port(62, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_C3_fraction<-lat_bnds_variable', 56, 32).
port(63, 'in', 'C3_Data', 'main.generate_netcdf_file_for_C3_fraction<-C3_Data', 57, 38).
port(64, 'out', 'C3_fraction_data', 'main.generate_netcdf_file_for_C3_fraction->C3_fraction_data', 58, 40).
port(65, 'in', 'lon_variable', 'main.generate_netcdf_file_for_C4_fraction<-lon_variable', 62, 29).
port(66, 'in', 'lat_variable', 'main.generate_netcdf_file_for_C4_fraction<-lat_variable', 63, 30).
port(67, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_C4_fraction<-lon_bnds_variable', 64, 31).
port(68, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_C4_fraction<-lat_bnds_variable', 65, 32).
port(69, 'in', 'C4_Data', 'main.generate_netcdf_file_for_C4_fraction<-C4_Data', 66, 39).
port(70, 'out', 'C4_fraction_data', 'main.generate_netcdf_file_for_C4_fraction->C4_fraction_data', 67, 41).
port(71, 'in', 'lon_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lon_variable', 71, 29).
port(72, 'in', 'lat_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lat_variable', 72, 30).
port(73, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lon_bnds_variable', 73, 31).
port(74, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lat_bnds_variable', 74, 32).
port(75, 'in', 'Grass_variable', 'main.generate_netcdf_file_for_Grass_fraction<-Grass_variable', 75, 37).
port(76, 'out', 'Grass_fraction_data', 'main.generate_netcdf_file_for_Grass_fraction->Grass_fraction_data', 76, 42).

% FACT: port_alias(port_id, alias).
port_alias(39, 'SYNMAP_land_cover_map_data').
port_alias(45, 'SYNMAP_land_cover_map_data').
port_alias(46, 'lon_variable').
port_alias(47, 'lat_variable').
port_alias(48, 'lon_bnds_variable').
port_alias(49, 'lat_bnds_variable').
port_alias(51, 'Tair_Matrix').
port_alias(53, 'Rain_Matrix').
port_alias(54, 'Grass_variable').
port_alias(55, 'Tair_Matrix').
port_alias(56, 'Rain_Matrix').
port_alias(57, 'C3_Data').
port_alias(58, 'C4_Data').

% FACT: port_uri_template(port_id, uri).
port_uri_template(40, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri_template(41, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri_template(42, 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(43, 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(44, 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
port_uri_template(50, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri_template(52, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri_template(64, 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(70, 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(76, 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').

% FACT: has_in_port(block_id, port_id).
has_in_port(1, 39).
has_in_port(1, 40).
has_in_port(1, 41).
has_in_port(2, 45).
has_in_port(3, 50).
has_in_port(4, 52).
has_in_port(6, 55).
has_in_port(6, 56).
has_in_port(7, 59).
has_in_port(7, 60).
has_in_port(7, 61).
has_in_port(7, 62).
has_in_port(7, 63).
has_in_port(8, 65).
has_in_port(8, 66).
has_in_port(8, 67).
has_in_port(8, 68).
has_in_port(8, 69).
has_in_port(9, 71).
has_in_port(9, 72).
has_in_port(9, 73).
has_in_port(9, 74).
has_in_port(9, 75).

% FACT: has_out_port(block_id, port_id).
has_out_port(1, 42).
has_out_port(1, 43).
has_out_port(1, 44).
has_out_port(2, 46).
has_out_port(2, 47).
has_out_port(2, 48).
has_out_port(2, 49).
has_out_port(3, 51).
has_out_port(4, 53).
has_out_port(5, 54).
has_out_port(6, 57).
has_out_port(6, 58).
has_out_port(7, 64).
has_out_port(8, 70).
has_out_port(9, 76).

% FACT: data(data_id, data_name, qualified_data_name).
data(22, 'SYNMAP_land_cover_map_data', '[SYNMAP_land_cover_map_data]').
data(23, 'mean_airtemp', '[mean_airtemp]').
data(24, 'mean_precip', '[mean_precip]').
data(25, 'C3_fraction_data', '[C3_fraction_data]').
data(26, 'C4_fraction_data', '[C4_fraction_data]').
data(27, 'Grass_fraction_data', '[Grass_fraction_data]').
data(28, 'SYNMAP_land_cover_map_data', 'main[SYNMAP_land_cover_map_data]').
data(29, 'lon_variable', 'main[lon_variable]').
data(30, 'lat_variable', 'main[lat_variable]').
data(31, 'lon_bnds_variable', 'main[lon_bnds_variable]').
data(32, 'lat_bnds_variable', 'main[lat_bnds_variable]').
data(33, 'mean_airtemp', 'main[mean_airtemp]').
data(34, 'Tair_Matrix', 'main[Tair_Matrix]').
data(35, 'mean_precip', 'main[mean_precip]').
data(36, 'Rain_Matrix', 'main[Rain_Matrix]').
data(37, 'Grass_variable', 'main[Grass_variable]').
data(38, 'C3_Data', 'main[C3_Data]').
data(39, 'C4_Data', 'main[C4_Data]').
data(40, 'C3_fraction_data', 'main[C3_fraction_data]').
data(41, 'C4_fraction_data', 'main[C4_fraction_data]').
data(42, 'Grass_fraction_data', 'main[Grass_fraction_data]').

% FACT: channel(channel_id, data_id).
channel(30, 25).
channel(31, 26).
channel(32, 27).
channel(33, 28).
channel(34, 33).
channel(35, 35).
channel(36, 34).
channel(37, 36).
channel(38, 29).
channel(39, 29).
channel(40, 29).
channel(41, 30).
channel(42, 30).
channel(43, 30).
channel(44, 31).
channel(45, 31).
channel(46, 31).
channel(47, 32).
channel(48, 32).
channel(49, 32).
channel(50, 38).
channel(51, 39).
channel(52, 37).
channel(53, 22).
channel(54, 23).
channel(55, 24).
channel(56, 40).
channel(57, 41).
channel(58, 42).

% FACT: port_connects_to_channel(port_id, channel_id).
port_connects_to_channel(64, 30).
port_connects_to_channel(70, 31).
port_connects_to_channel(76, 32).
port_connects_to_channel(45, 33).
port_connects_to_channel(50, 34).
port_connects_to_channel(52, 35).
port_connects_to_channel(51, 36).
port_connects_to_channel(55, 36).
port_connects_to_channel(53, 37).
port_connects_to_channel(56, 37).
port_connects_to_channel(46, 38).
port_connects_to_channel(59, 38).
port_connects_to_channel(46, 39).
port_connects_to_channel(65, 39).
port_connects_to_channel(46, 40).
port_connects_to_channel(71, 40).
port_connects_to_channel(47, 41).
port_connects_to_channel(60, 41).
port_connects_to_channel(47, 42).
port_connects_to_channel(66, 42).
port_connects_to_channel(47, 43).
port_connects_to_channel(72, 43).
port_connects_to_channel(48, 44).
port_connects_to_channel(61, 44).
port_connects_to_channel(48, 45).
port_connects_to_channel(67, 45).
port_connects_to_channel(48, 46).
port_connects_to_channel(73, 46).
port_connects_to_channel(49, 47).
port_connects_to_channel(62, 47).
port_connects_to_channel(49, 48).
port_connects_to_channel(68, 48).
port_connects_to_channel(49, 49).
port_connects_to_channel(74, 49).
port_connects_to_channel(57, 50).
port_connects_to_channel(63, 50).
port_connects_to_channel(58, 51).
port_connects_to_channel(69, 51).
port_connects_to_channel(54, 52).
port_connects_to_channel(75, 52).
port_connects_to_channel(45, 53).
port_connects_to_channel(50, 54).
port_connects_to_channel(52, 55).
port_connects_to_channel(64, 56).
port_connects_to_channel(70, 57).
port_connects_to_channel(76, 58).

% FACT: inflow_connects_to_channel(port_id, channel_id).
inflow_connects_to_channel(39, 33).
inflow_connects_to_channel(40, 34).
inflow_connects_to_channel(41, 35).
inflow_connects_to_channel(39, 53).
inflow_connects_to_channel(40, 54).
inflow_connects_to_channel(41, 55).

% FACT: outflow_connects_to_channel(port_id, channel_id).
outflow_connects_to_channel(42, 30).
outflow_connects_to_channel(43, 31).
outflow_connects_to_channel(44, 32).
outflow_connects_to_channel(42, 56).
outflow_connects_to_channel(43, 57).
outflow_connects_to_channel(44, 58).

% FACT: uri_variable(uri_variable_id, variable_name, port_id).
uri_variable(5, 'month', 40).
uri_variable(6, 'month', 41).
uri_variable(7, 'month', 50).
uri_variable(8, 'month', 52).
