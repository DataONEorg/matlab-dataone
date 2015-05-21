
% FACT: program(program_id, program_name, begin_annotation_id, end_annotation_id).
program(1, 'main', 1, 112).
program(2, 'fetch_SYNMAP_land_cover_map_variable', 14, 43).
program(3, 'fetch_monthly_mean_air_temperature_data', 44, 49).
program(4, 'fetch_monthly_mean_precipitation_data', 50, 55).
program(5, 'initialize_Grass_Matrix', 56, 59).
program(6, 'examine_pixels_for_grass', 60, 69).
program(7, 'output_netcdf_file_for_C3_fraction', 70, 83).
program(8, 'output_netcdf_file_for_C4_fraction', 84, 97).
program(9, 'output_netcdf_file_for_Grass_fraction', 98, 111).

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
port(8, 'out', 'sncid', 17).
port(9, 'out', 'fvid', 19).
port(10, 'out', 'frac', 21).
port(11, 'out', 'tvid', 23).
port(12, 'out', 'type', 25).
port(13, 'out', 'lon_vid', 27).
port(14, 'out', 'lon', 29).
port(15, 'out', 'lat_vid', 31).
port(16, 'out', 'lat', 33).
port(17, 'out', 'lon_bnds_vid', 35).
port(18, 'out', 'lon_bnds', 37).
port(19, 'out', 'lat_bnds_vid', 39).
port(20, 'out', 'lat_bnds', 41).
port(21, 'in', 'mean_airtemp', 45).
port(22, 'out', 'Tair', 47).
port(23, 'in', 'mean_precip', 51).
port(24, 'out', 'Rain', 53).
port(25, 'out', 'Grass', 57).
port(26, 'in', 'Tair', 61).
port(27, 'in', 'Rain', 63).
port(28, 'out', 'C3', 65).
port(29, 'out', 'C4', 67).
port(30, 'in', 'lon', 71).
port(31, 'in', 'lat', 73).
port(32, 'in', 'lon_bnds', 75).
port(33, 'in', 'lat_bnds', 77).
port(34, 'in', 'C3', 79).
port(35, 'out', 'mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc', 81).
port(36, 'in', 'lon', 85).
port(37, 'in', 'lat', 87).
port(38, 'in', 'lon_bnds', 89).
port(39, 'in', 'lat_bnds', 91).
port(40, 'in', 'C4', 93).
port(41, 'out', 'mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc', 95).
port(42, 'in', 'lon', 99).
port(43, 'in', 'lat', 101).
port(44, 'in', 'lon_bnds', 103).
port(45, 'in', 'lat_bnds', 105).
port(46, 'in', 'Grass', 107).
port(47, 'out', 'mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc', 109).

% FACT: port_alias(port_id, alias).
port_alias(1, 'SYNMAP_land_cover_map_data').
port_alias(4, 'output_C3_fraction_data').
port_alias(5, 'output_C4_fraction_data').
port_alias(6, 'output_Grass_fraction_data').
port_alias(7, 'SYNMAP_land_cover_map_data').
port_alias(8, 'sncid_variable').
port_alias(9, 'fvid_variable').
port_alias(10, 'frac_variable').
port_alias(11, 'tvid_variable').
port_alias(12, 'type_variable').
port_alias(13, 'lon_vid_variable').
port_alias(14, 'lon_variable').
port_alias(15, 'lat_vid_variable').
port_alias(16, 'lat_variable').
port_alias(17, 'lon_bnds_vid_variable').
port_alias(18, 'lon_bnds_variable').
port_alias(19, 'lat_bnds_vid_variable').
port_alias(20, 'lat_bnds_variable').
port_alias(22, 'Tair_Matrix').
port_alias(24, 'Rain_Matrix').
port_alias(25, 'Grass_variable').
port_alias(26, 'Tair_Matrix').
port_alias(27, 'Rain_Matrix').
port_alias(28, 'C3_Data').
port_alias(29, 'C4_Data').
port_alias(30, 'lon_variable').
port_alias(31, 'lat_variable').
port_alias(32, 'lon_bnds_variable').
port_alias(33, 'lat_bnds_variable').
port_alias(34, 'C3_Data').
port_alias(35, 'output_C3_fraction_data').
port_alias(36, 'lon_variable').
port_alias(37, 'lat_variable').
port_alias(38, 'lon_bnds_variable').
port_alias(39, 'lat_bnds_variable').
port_alias(40, 'C4_Data').
port_alias(41, 'output_C4_fraction_data').
port_alias(42, 'lon_variable').
port_alias(43, 'lat_variable').
port_alias(44, 'lon_bnds_variable').
port_alias(45, 'lat_bnds_variable').
port_alias(46, 'Grass_variable').
port_alias(47, 'output_Grass_fraction_data').

% FACT: port_uri(port_id, uri).
port_uri(2, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri(3, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
port_uri(21, 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
port_uri(23, 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').

% FACT: has_in_port(block_id, port_id).
has_in_port(1, 1).
has_in_port(1, 2).
has_in_port(1, 3).
has_in_port(2, 7).
has_in_port(3, 21).
has_in_port(4, 23).
has_in_port(6, 26).
has_in_port(6, 27).
has_in_port(7, 30).
has_in_port(7, 31).
has_in_port(7, 32).
has_in_port(7, 33).
has_in_port(7, 34).
has_in_port(8, 36).
has_in_port(8, 37).
has_in_port(8, 38).
has_in_port(8, 39).
has_in_port(8, 40).
has_in_port(9, 42).
has_in_port(9, 43).
has_in_port(9, 44).
has_in_port(9, 45).
has_in_port(9, 46).

% FACT: has_out_port(block_id, port_id).
has_out_port(1, 4).
has_out_port(1, 5).
has_out_port(1, 6).
has_out_port(2, 8).
has_out_port(2, 9).
has_out_port(2, 10).
has_out_port(2, 11).
has_out_port(2, 12).
has_out_port(2, 13).
has_out_port(2, 14).
has_out_port(2, 15).
has_out_port(2, 16).
has_out_port(2, 17).
has_out_port(2, 18).
has_out_port(2, 19).
has_out_port(2, 20).
has_out_port(3, 22).
has_out_port(4, 24).
has_out_port(5, 25).
has_out_port(6, 28).
has_out_port(6, 29).
has_out_port(7, 35).
has_out_port(8, 41).
has_out_port(9, 47).

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
port_connects_to_channel(35, 1).
port_connects_to_channel(4, 1).
port_connects_to_channel(41, 2).
port_connects_to_channel(5, 2).
port_connects_to_channel(47, 3).
port_connects_to_channel(6, 3).
port_connects_to_channel(1, 4).
port_connects_to_channel(7, 4).
port_connects_to_channel(2, 5).
port_connects_to_channel(21, 5).
port_connects_to_channel(3, 6).
port_connects_to_channel(23, 6).
port_connects_to_channel(22, 7).
port_connects_to_channel(26, 7).
port_connects_to_channel(24, 8).
port_connects_to_channel(27, 8).
port_connects_to_channel(14, 9).
port_connects_to_channel(30, 9).
port_connects_to_channel(14, 10).
port_connects_to_channel(36, 10).
port_connects_to_channel(14, 11).
port_connects_to_channel(42, 11).
port_connects_to_channel(16, 12).
port_connects_to_channel(31, 12).
port_connects_to_channel(16, 13).
port_connects_to_channel(37, 13).
port_connects_to_channel(16, 14).
port_connects_to_channel(43, 14).
port_connects_to_channel(18, 15).
port_connects_to_channel(32, 15).
port_connects_to_channel(18, 16).
port_connects_to_channel(38, 16).
port_connects_to_channel(18, 17).
port_connects_to_channel(44, 17).
port_connects_to_channel(20, 18).
port_connects_to_channel(33, 18).
port_connects_to_channel(20, 19).
port_connects_to_channel(39, 19).
port_connects_to_channel(20, 20).
port_connects_to_channel(45, 20).
port_connects_to_channel(28, 21).
port_connects_to_channel(34, 21).
port_connects_to_channel(29, 22).
port_connects_to_channel(40, 22).
port_connects_to_channel(25, 23).
port_connects_to_channel(46, 23).

% FACT: uri_variable(uri_variable_id, variable_name, port_id).
uri_variable(1, 'month', 2).
uri_variable(2, 'month', 3).
uri_variable(3, 'month', 21).
uri_variable(4, 'month', 23).
