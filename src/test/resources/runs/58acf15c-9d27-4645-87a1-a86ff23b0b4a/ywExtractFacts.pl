
% FACT: extract_source(source_id, source_path).
extract_source(1, '_reader__').

% FACT: annotation(annotation_id, source_id, line_number, annotation_tag, annotation_value).
annotation(1, 1, 1, '@begin', 'main').
annotation(2, 1, 2, '@in', 'mstmip_SYNMAP_NA_QD.nc').
annotation(3, 1, 2, '@as', 'SYNMAP_land_cover_map_data').
annotation(4, 1, 3, '@in', 'mean_airtemp').
annotation(5, 1, 3, '@uri', 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
annotation(6, 1, 4, '@in', 'mean_precip').
annotation(7, 1, 4, '@uri', 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
annotation(8, 1, 6, '@out', 'mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
annotation(9, 1, 6, '@as', 'output_C3_fraction_data').
annotation(10, 1, 7, '@out', 'mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
annotation(11, 1, 7, '@as', 'output_C4_fraction_data').
annotation(12, 1, 8, '@out', 'mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
annotation(13, 1, 8, '@as', 'output_Grass_fraction_data').
annotation(14, 1, 15, '@begin', 'fetch_SYNMAP_land_cover_map_variable').
annotation(15, 1, 16, '@in', 'mstmip_SYNMAP_NA_QD.nc').
annotation(16, 1, 16, '@as', 'SYNMAP_land_cover_map_data').
annotation(17, 1, 17, '@out', 'sncid').
annotation(18, 1, 17, '@as', 'sncid_variable').
annotation(19, 1, 18, '@out', 'fvid').
annotation(20, 1, 18, '@as', 'fvid_variable').
annotation(21, 1, 19, '@out', 'frac').
annotation(22, 1, 19, '@as', 'frac_variable').
annotation(23, 1, 20, '@out', 'tvid').
annotation(24, 1, 20, '@as', 'tvid_variable').
annotation(25, 1, 21, '@out', 'type').
annotation(26, 1, 21, '@as', 'type_variable').
annotation(27, 1, 22, '@out', 'lon_vid').
annotation(28, 1, 22, '@as', 'lon_vid_variable').
annotation(29, 1, 23, '@out', 'lon').
annotation(30, 1, 23, '@as', 'lon_variable').
annotation(31, 1, 24, '@out', 'lat_vid').
annotation(32, 1, 24, '@as', 'lat_vid_variable').
annotation(33, 1, 25, '@out', 'lat').
annotation(34, 1, 25, '@as', 'lat_variable').
annotation(35, 1, 26, '@out', 'lon_bnds_vid').
annotation(36, 1, 26, '@as', 'lon_bnds_vid_variable').
annotation(37, 1, 27, '@out', 'lon_bnds').
annotation(38, 1, 27, '@as', 'lon_bnds_variable').
annotation(39, 1, 28, '@out', 'lat_bnds_vid').
annotation(40, 1, 28, '@as', 'lat_bnds_vid_variable').
annotation(41, 1, 29, '@out', 'lat_bnds').
annotation(42, 1, 29, '@as', 'lat_bnds_variable').
annotation(43, 1, 49, '@end', 'fetch_SYNMAP_land_cover_map_variable').
annotation(44, 1, 52, '@begin', 'fetch_monthly_mean_air_temperature_data').
annotation(45, 1, 53, '@in', 'mean_airtemp').
annotation(46, 1, 53, '@uri', 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
annotation(47, 1, 54, '@out', 'Tair').
annotation(48, 1, 54, '@as', 'Tair_Matrix').
annotation(49, 1, 64, '@end', 'fetch_monthly_mean_air_temperature_data').
annotation(50, 1, 67, '@begin', 'fetch_monthly_mean_precipitation_data').
annotation(51, 1, 68, '@in', 'mean_precip').
annotation(52, 1, 68, '@uri', 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
annotation(53, 1, 69, '@out', 'Rain').
annotation(54, 1, 69, '@as', 'Rain_Matrix').
annotation(55, 1, 79, '@end', 'fetch_monthly_mean_precipitation_data').
annotation(56, 1, 81, '@begin', 'initialize_Grass_Matrix').
annotation(57, 1, 82, '@out', 'Grass').
annotation(58, 1, 82, '@as', 'Grass_variable').
annotation(59, 1, 91, '@end', 'initialize_Grass_Matrix').
annotation(60, 1, 94, '@begin', 'examine_pixels_for_grass').
annotation(61, 1, 95, '@in', 'Tair').
annotation(62, 1, 95, '@as', 'Tair_Matrix').
annotation(63, 1, 96, '@in', 'Rain').
annotation(64, 1, 96, '@as', 'Rain_Matrix').
annotation(65, 1, 97, '@out', 'C3').
annotation(66, 1, 97, '@as', 'C3_Data').
annotation(67, 1, 98, '@out', 'C4').
annotation(68, 1, 98, '@as', 'C4_Data').
annotation(69, 1, 136, '@end', 'examine_pixels_for_grass').
annotation(70, 1, 179, '@begin', 'output_netcdf_file_for_C3_fraction').
annotation(71, 1, 180, '@in', 'lon').
annotation(72, 1, 180, '@as', 'lon_variable').
annotation(73, 1, 181, '@in', 'lat').
annotation(74, 1, 181, '@as', 'lat_variable').
annotation(75, 1, 182, '@in', 'lon_bnds').
annotation(76, 1, 182, '@as', 'lon_bnds_variable').
annotation(77, 1, 183, '@in', 'lat_bnds').
annotation(78, 1, 183, '@as', 'lat_bnds_variable').
annotation(79, 1, 184, '@in', 'C3').
annotation(80, 1, 184, '@as', 'C3_Data').
annotation(81, 1, 185, '@out', 'mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
annotation(82, 1, 185, '@as', 'output_C3_fraction_data').
annotation(83, 1, 239, '@end', 'output_netcdf_file_for_C3_fraction').
annotation(84, 1, 243, '@begin', 'output_netcdf_file_for_C4_fraction').
annotation(85, 1, 244, '@in', 'lon').
annotation(86, 1, 244, '@as', 'lon_variable').
annotation(87, 1, 245, '@in', 'lat').
annotation(88, 1, 245, '@as', 'lat_variable').
annotation(89, 1, 246, '@in', 'lon_bnds').
annotation(90, 1, 246, '@as', 'lon_bnds_variable').
annotation(91, 1, 247, '@in', 'lat_bnds').
annotation(92, 1, 247, '@as', 'lat_bnds_variable').
annotation(93, 1, 248, '@in', 'C4').
annotation(94, 1, 248, '@as', 'C4_Data').
annotation(95, 1, 249, '@out', 'mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
annotation(96, 1, 249, '@as', 'output_C4_fraction_data').
annotation(97, 1, 302, '@end', 'output_netcdf_file_for_C4_fraction').
annotation(98, 1, 305, '@begin', 'output_netcdf_file_for_Grass_fraction').
annotation(99, 1, 306, '@in', 'lon').
annotation(100, 1, 306, '@as', 'lon_variable').
annotation(101, 1, 307, '@in', 'lat').
annotation(102, 1, 307, '@as', 'lat_variable').
annotation(103, 1, 308, '@in', 'lon_bnds').
annotation(104, 1, 308, '@as', 'lon_bnds_variable').
annotation(105, 1, 309, '@in', 'lat_bnds').
annotation(106, 1, 309, '@as', 'lat_bnds_variable').
annotation(107, 1, 310, '@in', 'Grass').
annotation(108, 1, 310, '@as', 'Grass_variable').
annotation(109, 1, 311, '@out', 'mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
annotation(110, 1, 311, '@as', 'output_Grass_fraction_data').
annotation(111, 1, 364, '@end', 'output_netcdf_file_for_Grass_fraction').
annotation(112, 1, 367, '@end', 'main').

% FACT: annotation_description(annotation_id, annotation_description).

% FACT: annotation_qualifies(qualifying_annotation_id, primary_annotation_id).
annotation_qualifies(3, 2).
annotation_qualifies(5, 4).
annotation_qualifies(7, 6).
annotation_qualifies(9, 8).
annotation_qualifies(11, 10).
annotation_qualifies(13, 12).
annotation_qualifies(16, 15).
annotation_qualifies(18, 17).
annotation_qualifies(20, 19).
annotation_qualifies(22, 21).
annotation_qualifies(24, 23).
annotation_qualifies(26, 25).
annotation_qualifies(28, 27).
annotation_qualifies(30, 29).
annotation_qualifies(32, 31).
annotation_qualifies(34, 33).
annotation_qualifies(36, 35).
annotation_qualifies(38, 37).
annotation_qualifies(40, 39).
annotation_qualifies(42, 41).
annotation_qualifies(46, 45).
annotation_qualifies(48, 47).
annotation_qualifies(52, 51).
annotation_qualifies(54, 53).
annotation_qualifies(58, 57).
annotation_qualifies(62, 61).
annotation_qualifies(64, 63).
annotation_qualifies(66, 65).
annotation_qualifies(68, 67).
annotation_qualifies(72, 71).
annotation_qualifies(74, 73).
annotation_qualifies(76, 75).
annotation_qualifies(78, 77).
annotation_qualifies(80, 79).
annotation_qualifies(82, 81).
annotation_qualifies(86, 85).
annotation_qualifies(88, 87).
annotation_qualifies(90, 89).
annotation_qualifies(92, 91).
annotation_qualifies(94, 93).
annotation_qualifies(96, 95).
annotation_qualifies(100, 99).
annotation_qualifies(102, 101).
annotation_qualifies(104, 103).
annotation_qualifies(106, 105).
annotation_qualifies(108, 107).
annotation_qualifies(110, 109).
