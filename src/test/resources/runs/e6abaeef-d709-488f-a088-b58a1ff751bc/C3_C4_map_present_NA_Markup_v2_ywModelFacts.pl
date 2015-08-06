
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
port(1, 'in', 'mstmip_SYNMAP_NA_QD.nc', 'main<-mstmip_SYNMAP_NA_QD.nc', 2, 1).
port(2, 'in', 'mean_airtemp', 'main<-mean_airtemp', 4, 2).
port(3, 'in', 'mean_precip', 'main<-mean_precip', 6, 3).
port(4, 'out', 'C3_fraction_data', 'main->C3_fraction_data', 8, 4).
port(5, 'out', 'C4_fraction_data', 'main->C4_fraction_data', 10, 5).
port(6, 'out', 'Grass_fraction_data', 'main->Grass_fraction_data', 12, 6).
port(7, 'in', 'mstmip_SYNMAP_NA_QD.nc', 'main.fetch_SYNMAP_land_cover_map_variable<-mstmip_SYNMAP_NA_QD.nc', 15, 7).
port(8, 'out', 'lon', 'main.fetch_SYNMAP_land_cover_map_variable->lon', 17, 8).
port(9, 'out', 'lat', 'main.fetch_SYNMAP_land_cover_map_variable->lat', 19, 9).
port(10, 'out', 'lon_bnds', 'main.fetch_SYNMAP_land_cover_map_variable->lon_bnds', 21, 10).
port(11, 'out', 'lat_bnds', 'main.fetch_SYNMAP_land_cover_map_variable->lat_bnds', 23, 11).
port(12, 'in', 'mean_airtemp', 'main.fetch_monthly_mean_air_temperature_data<-mean_airtemp', 27, 12).
port(13, 'out', 'Tair', 'main.fetch_monthly_mean_air_temperature_data->Tair', 29, 13).
port(14, 'in', 'mean_precip', 'main.fetch_monthly_mean_precipitation_data<-mean_precip', 33, 14).
port(15, 'out', 'Rain', 'main.fetch_monthly_mean_precipitation_data->Rain', 35, 15).
port(16, 'out', 'Grass', 'main.initialize_Grass_Matrix->Grass', 39, 16).
port(17, 'in', 'Tair', 'main.examine_pixels_for_grass<-Tair', 43, 13).
port(18, 'in', 'Rain', 'main.examine_pixels_for_grass<-Rain', 45, 15).
port(19, 'out', 'C3', 'main.examine_pixels_for_grass->C3', 47, 17).
port(20, 'out', 'C4', 'main.examine_pixels_for_grass->C4', 49, 18).
port(21, 'in', 'lon_variable', 'main.generate_netcdf_file_for_C3_fraction<-lon_variable', 53, 8).
port(22, 'in', 'lat_variable', 'main.generate_netcdf_file_for_C3_fraction<-lat_variable', 54, 9).
port(23, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_C3_fraction<-lon_bnds_variable', 55, 10).
port(24, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_C3_fraction<-lat_bnds_variable', 56, 11).
port(25, 'in', 'C3_Data', 'main.generate_netcdf_file_for_C3_fraction<-C3_Data', 57, 17).
port(26, 'out', 'C3_fraction_data', 'main.generate_netcdf_file_for_C3_fraction->C3_fraction_data', 58, 19).
port(27, 'in', 'lon_variable', 'main.generate_netcdf_file_for_C4_fraction<-lon_variable', 62, 8).
port(28, 'in', 'lat_variable', 'main.generate_netcdf_file_for_C4_fraction<-lat_variable', 63, 9).
port(29, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_C4_fraction<-lon_bnds_variable', 64, 10).
port(30, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_C4_fraction<-lat_bnds_variable', 65, 11).
port(31, 'in', 'C4_Data', 'main.generate_netcdf_file_for_C4_fraction<-C4_Data', 66, 18).
port(32, 'out', 'C4_fraction_data', 'main.generate_netcdf_file_for_C4_fraction->C4_fraction_data', 67, 20).
port(33, 'in', 'lon_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lon_variable', 71, 8).
port(34, 'in', 'lat_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lat_variable', 72, 9).
port(35, 'in', 'lon_bnds_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lon_bnds_variable', 73, 10).
port(36, 'in', 'lat_bnds_variable', 'main.generate_netcdf_file_for_Grass_fraction<-lat_bnds_variable', 74, 11).
port(37, 'in', 'Grass_variable', 'main.generate_netcdf_file_for_Grass_fraction<-Grass_variable', 75, 16).
port(38, 'out', 'Grass_fraction_data', 'main.generate_netcdf_file_for_Grass_fraction->Grass_fraction_data', 76, 21).

% FACT: port_alias(port_id, alias).
port_alias(1, 'SYNMAP_land_cover_map_data').
port_alias(7, 'SYNMAP_land_cover_map_data').
port_alias(8, 'lon_variable').
port_alias(9, 'lat_variable').
port_alias(10, 'lon_bnds_variable').
port_alias(11, 'lat_bnds_variable').
port_alias(13, 'Tair_Matrix').
port_alias(15, 'Rain_Matrix').
port_alias(16, 'Grass_variable').
port_alias(17, 'Tair_Matrix').
port_alias(18, 'Rain_Matrix').
port_alias(19, 'C3_Data').
port_alias(20, 'C4_Data').

% FACT: port_uri_template(port_id, uri).
port_uri_template(2, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri_template(3, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri_template(4, 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(5, 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(6, 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
port_uri_template(12, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri_template(14, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri_template(26, 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(32, 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
port_uri_template(38, 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').

% FACT: has_in_port(block_id, port_id).
has_in_port(1, 1).
has_in_port(1, 2).
has_in_port(1, 3).
has_in_port(2, 7).
has_in_port(3, 12).
has_in_port(4, 14).
has_in_port(6, 17).
has_in_port(6, 18).
has_in_port(7, 21).
has_in_port(7, 22).
has_in_port(7, 23).
has_in_port(7, 24).
has_in_port(7, 25).
has_in_port(8, 27).
has_in_port(8, 28).
has_in_port(8, 29).
has_in_port(8, 30).
has_in_port(8, 31).
has_in_port(9, 33).
has_in_port(9, 34).
has_in_port(9, 35).
has_in_port(9, 36).
has_in_port(9, 37).

% FACT: has_out_port(block_id, port_id).
has_out_port(1, 4).
has_out_port(1, 5).
has_out_port(1, 6).
has_out_port(2, 8).
has_out_port(2, 9).
has_out_port(2, 10).
has_out_port(2, 11).
has_out_port(3, 13).
has_out_port(4, 15).
has_out_port(5, 16).
has_out_port(6, 19).
has_out_port(6, 20).
has_out_port(7, 26).
has_out_port(8, 32).
has_out_port(9, 38).

% FACT: data(data_id, data_name, qualified_data_name).
data(1, 'SYNMAP_land_cover_map_data', '[SYNMAP_land_cover_map_data]').
data(2, 'mean_airtemp', '[mean_airtemp]').
data(3, 'mean_precip', '[mean_precip]').
data(4, 'C3_fraction_data', '[C3_fraction_data]').
data(5, 'C4_fraction_data', '[C4_fraction_data]').
data(6, 'Grass_fraction_data', '[Grass_fraction_data]').
data(7, 'SYNMAP_land_cover_map_data', 'main[SYNMAP_land_cover_map_data]').
data(8, 'lon_variable', 'main[lon_variable]').
data(9, 'lat_variable', 'main[lat_variable]').
data(10, 'lon_bnds_variable', 'main[lon_bnds_variable]').
data(11, 'lat_bnds_variable', 'main[lat_bnds_variable]').
data(12, 'mean_airtemp', 'main[mean_airtemp]').
data(13, 'Tair_Matrix', 'main[Tair_Matrix]').
data(14, 'mean_precip', 'main[mean_precip]').
data(15, 'Rain_Matrix', 'main[Rain_Matrix]').
data(16, 'Grass_variable', 'main[Grass_variable]').
data(17, 'C3_Data', 'main[C3_Data]').
data(18, 'C4_Data', 'main[C4_Data]').
data(19, 'C3_fraction_data', 'main[C3_fraction_data]').
data(20, 'C4_fraction_data', 'main[C4_fraction_data]').
data(21, 'Grass_fraction_data', 'main[Grass_fraction_data]').

% FACT: channel(channel_id, data_id).
channel(1, 4).
channel(2, 5).
channel(3, 6).
channel(4, 7).
channel(5, 12).
channel(6, 14).
channel(7, 13).
channel(8, 15).
channel(9, 8).
channel(10, 8).
channel(11, 8).
channel(12, 9).
channel(13, 9).
channel(14, 9).
channel(15, 10).
channel(16, 10).
channel(17, 10).
channel(18, 11).
channel(19, 11).
channel(20, 11).
channel(21, 17).
channel(22, 18).
channel(23, 16).
channel(24, 1).
channel(25, 2).
channel(26, 3).
channel(27, 19).
channel(28, 20).
channel(29, 21).

% FACT: port_connects_to_channel(port_id, channel_id).
port_connects_to_channel(26, 1).
port_connects_to_channel(32, 2).
port_connects_to_channel(38, 3).
port_connects_to_channel(7, 4).
port_connects_to_channel(12, 5).
port_connects_to_channel(14, 6).
port_connects_to_channel(13, 7).
port_connects_to_channel(17, 7).
port_connects_to_channel(15, 8).
port_connects_to_channel(18, 8).
port_connects_to_channel(8, 9).
port_connects_to_channel(21, 9).
port_connects_to_channel(8, 10).
port_connects_to_channel(27, 10).
port_connects_to_channel(8, 11).
port_connects_to_channel(33, 11).
port_connects_to_channel(9, 12).
port_connects_to_channel(22, 12).
port_connects_to_channel(9, 13).
port_connects_to_channel(28, 13).
port_connects_to_channel(9, 14).
port_connects_to_channel(34, 14).
port_connects_to_channel(10, 15).
port_connects_to_channel(23, 15).
port_connects_to_channel(10, 16).
port_connects_to_channel(29, 16).
port_connects_to_channel(10, 17).
port_connects_to_channel(35, 17).
port_connects_to_channel(11, 18).
port_connects_to_channel(24, 18).
port_connects_to_channel(11, 19).
port_connects_to_channel(30, 19).
port_connects_to_channel(11, 20).
port_connects_to_channel(36, 20).
port_connects_to_channel(19, 21).
port_connects_to_channel(25, 21).
port_connects_to_channel(20, 22).
port_connects_to_channel(31, 22).
port_connects_to_channel(16, 23).
port_connects_to_channel(37, 23).
port_connects_to_channel(7, 24).
port_connects_to_channel(12, 25).
port_connects_to_channel(14, 26).
port_connects_to_channel(26, 27).
port_connects_to_channel(32, 28).
port_connects_to_channel(38, 29).

% FACT: inflow_connects_to_channel(port_id, channel_id).
inflow_connects_to_channel(1, 4).
inflow_connects_to_channel(2, 5).
inflow_connects_to_channel(3, 6).
inflow_connects_to_channel(1, 24).
inflow_connects_to_channel(2, 25).
inflow_connects_to_channel(3, 26).

% FACT: outflow_connects_to_channel(port_id, channel_id).
outflow_connects_to_channel(4, 1).
outflow_connects_to_channel(5, 2).
outflow_connects_to_channel(6, 3).
outflow_connects_to_channel(4, 27).
outflow_connects_to_channel(5, 28).
outflow_connects_to_channel(6, 29).

% FACT: uri_variable(uri_variable_id, variable_name, port_id).
uri_variable(1, 'month', 2).
uri_variable(2, 'month', 3).
uri_variable(3, 'month', 12).
uri_variable(4, 'month', 14).
