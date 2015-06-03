
% FACT: program(program_id, program_name, begin_annotation_id, end_annotation_id).
program(1, 'main', 1, 79).
program(2, 'fetch_SYNMAP_land_cover_map_variable', 14, 25).
program(3, 'fetch_monthly_mean_air_temperature_data', 26, 31).
program(4, 'fetch_monthly_mean_precipitation_data', 32, 37).
program(5, 'initialize_Grass_Matrix', 38, 41).
program(6, 'examine_pixels_for_grass', 42, 51).
program(7, 'output_netcdf_file_for_C3_fraction', 52, 60).
program(8, 'output_netcdf_file_for_C4_fraction', 61, 69).
program(9, 'output_netcdf_file_for_Grass_fraction', 70, 78).

% FACT: workflow(program_id).
workflow(1).

% FACT: function(program_id).

% FACT: has_sub_program(program_id, subprogram_id).
has_sub_program(1, 2).
has_sub_program(1, 3).
has_sub_program(1, 4).
has_sub_program(1, 5).
has_sub_program(1, 6).
has_sub_program(1, 7).
has_sub_program(1, 8).
has_sub_program(1, 9).

% FACT: port(port_id, port_type, port_name, port_annotation_id).
port(1, 'in', 'mstmip_SYNMAP_NA_QD.nc', 2).
port(2, 'in', 'mean_airtemp', 4).
port(3, 'in', 'mean_precip', 6).
port(4, 'out', 'mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc', 8).
port(5, 'out', 'mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc', 10).
port(6, 'out', 'mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc', 12).
port(7, 'in', 'mstmip_SYNMAP_NA_QD.nc', 15).
port(8, 'out', 'lon', 17).
port(9, 'out', 'lat', 19).
port(10, 'out', 'lon_bnds', 21).
port(11, 'out', 'lat_bnds', 23).
port(12, 'in', 'mean_airtemp', 27).
port(13, 'out', 'Tair', 29).
port(14, 'in', 'mean_precip', 33).
port(15, 'out', 'Rain', 35).
port(16, 'out', 'Grass', 39).
port(17, 'in', 'Tair', 43).
port(18, 'in', 'Rain', 45).
port(19, 'out', 'C3', 47).
port(20, 'out', 'C4', 49).
port(21, 'in', 'lon_variable', 53).
port(22, 'in', 'lat_variable', 54).
port(23, 'in', 'lon_bnds_variable', 55).
port(24, 'in', 'lat_bnds_variable', 56).
port(25, 'in', 'C3_Data', 57).
port(26, 'out', 'mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc', 58).
port(27, 'in', 'lon_variable', 62).
port(28, 'in', 'lat_variable', 63).
port(29, 'in', 'lon_bnds_variable', 64).
port(30, 'in', 'lat_bnds_variable', 65).
port(31, 'in', 'C4_Data', 66).
port(32, 'out', 'mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc', 67).
port(33, 'in', 'lon_variable', 71).
port(34, 'in', 'lat_variable', 72).
port(35, 'in', 'lon_bnds_variable', 73).
port(36, 'in', 'lat_bnds_variable', 74).
port(37, 'in', 'Grass_variable', 75).
port(38, 'out', 'mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc', 76).

% FACT: port_alias(port_id, alias).
port_alias(1, 'SYNMAP_land_cover_map_data').
port_alias(4, 'output_C3_fraction_data').
port_alias(5, 'output_C4_fraction_data').
port_alias(6, 'output_Grass_fraction_data').
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
port_alias(26, 'output_C3_fraction_data').
port_alias(32, 'output_C4_fraction_data').
port_alias(38, 'output_Grass_fraction_data').

% FACT: port_uri(port_id, uri).
port_uri(2, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri(3, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri(12, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri(14, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').

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

% FACT: channel(channel_id, binding).
channel(1, 'output_C3_fraction_data').
channel(2, 'output_C4_fraction_data').
channel(3, 'output_Grass_fraction_data').
channel(4, 'SYNMAP_land_cover_map_data').
channel(5, 'mean_airtemp').
channel(6, 'mean_precip').
channel(7, 'Tair_Matrix').
channel(8, 'Rain_Matrix').
channel(9, 'lon_variable').
channel(10, 'lon_variable').
channel(11, 'lon_variable').
channel(12, 'lat_variable').
channel(13, 'lat_variable').
channel(14, 'lat_variable').
channel(15, 'lon_bnds_variable').
channel(16, 'lon_bnds_variable').
channel(17, 'lon_bnds_variable').
channel(18, 'lat_bnds_variable').
channel(19, 'lat_bnds_variable').
channel(20, 'lat_bnds_variable').
channel(21, 'C3_Data').
channel(22, 'C4_Data').
channel(23, 'Grass_variable').

% FACT: port_connects_to_channel(port_id, channel_id).
port_connects_to_channel(26, 1).
port_connects_to_channel(4, 1).
port_connects_to_channel(32, 2).
port_connects_to_channel(5, 2).
port_connects_to_channel(38, 3).
port_connects_to_channel(6, 3).
port_connects_to_channel(1, 4).
port_connects_to_channel(7, 4).
port_connects_to_channel(2, 5).
port_connects_to_channel(12, 5).
port_connects_to_channel(3, 6).
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

% FACT: uri_variable(uri_variable_id, variable_name, port_id).
uri_variable(1, 'month', 2).
uri_variable(2, 'month', 3).
uri_variable(3, 'month', 12).
uri_variable(4, 'month', 14).
