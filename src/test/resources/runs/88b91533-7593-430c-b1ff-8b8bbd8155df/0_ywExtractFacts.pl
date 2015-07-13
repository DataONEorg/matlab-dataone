
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
annotation(8, 1, 6, '@out', 'C3_fraction_data').
annotation(9, 1, 6, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
annotation(10, 1, 7, '@out', 'C4_fraction_data').
annotation(11, 1, 7, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
annotation(12, 1, 8, '@out', 'Grass_fraction_data').
annotation(13, 1, 8, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
annotation(14, 1, 15, '@begin', 'fetch_SYNMAP_land_cover_map_variable').
annotation(15, 1, 16, '@in', 'mstmip_SYNMAP_NA_QD.nc').
annotation(16, 1, 16, '@as', 'SYNMAP_land_cover_map_data').
annotation(17, 1, 17, '@out', 'lon').
annotation(18, 1, 17, '@as', 'lon_variable').
annotation(19, 1, 18, '@out', 'lat').
annotation(20, 1, 18, '@as', 'lat_variable').
annotation(21, 1, 19, '@out', 'lon_bnds').
annotation(22, 1, 19, '@as', 'lon_bnds_variable').
annotation(23, 1, 20, '@out', 'lat_bnds').
annotation(24, 1, 20, '@as', 'lat_bnds_variable').
annotation(25, 1, 40, '@end', 'fetch_SYNMAP_land_cover_map_variable').
annotation(26, 1, 43, '@begin', 'fetch_monthly_mean_air_temperature_data').
annotation(27, 1, 44, '@in', 'mean_airtemp').
annotation(28, 1, 44, '@uri', 'file:c3c4input/monthly/2000-2010/air.2m_monthly_2000_2010.mean.{month}.nc').
annotation(29, 1, 45, '@out', 'Tair').
annotation(30, 1, 45, '@as', 'Tair_Matrix').
annotation(31, 1, 55, '@end', 'fetch_monthly_mean_air_temperature_data').
annotation(32, 1, 58, '@begin', 'fetch_monthly_mean_precipitation_data').
annotation(33, 1, 59, '@in', 'mean_precip').
annotation(34, 1, 59, '@uri', 'file:c3c4input/monthly/2000-2010/apcp_monthly_2000_2010_mean.{month}.nc').
annotation(35, 1, 60, '@out', 'Rain').
annotation(36, 1, 60, '@as', 'Rain_Matrix').
annotation(37, 1, 70, '@end', 'fetch_monthly_mean_precipitation_data').
annotation(38, 1, 72, '@begin', 'initialize_Grass_Matrix').
annotation(39, 1, 73, '@out', 'Grass').
annotation(40, 1, 73, '@as', 'Grass_variable').
annotation(41, 1, 82, '@end', 'initialize_Grass_Matrix').
annotation(42, 1, 85, '@begin', 'examine_pixels_for_grass').
annotation(43, 1, 86, '@in', 'Tair').
annotation(44, 1, 86, '@as', 'Tair_Matrix').
annotation(45, 1, 87, '@in', 'Rain').
annotation(46, 1, 87, '@as', 'Rain_Matrix').
annotation(47, 1, 88, '@out', 'C3').
annotation(48, 1, 88, '@as', 'C3_Data').
annotation(49, 1, 89, '@out', 'C4').
annotation(50, 1, 89, '@as', 'C4_Data').
annotation(51, 1, 127, '@end', 'examine_pixels_for_grass').
annotation(52, 1, 170, '@begin', 'generate_netcdf_file_for_C3_fraction').
annotation(53, 1, 171, '@in', 'lon_variable').
annotation(54, 1, 172, '@in', 'lat_variable').
annotation(55, 1, 173, '@in', 'lon_bnds_variable').
annotation(56, 1, 174, '@in', 'lat_bnds_variable').
annotation(57, 1, 175, '@in', 'C3_Data').
annotation(58, 1, 176, '@out', 'C3_fraction_data').
annotation(59, 1, 176, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_C3Grass_RelaFrac_NA_v2.0.nc').
annotation(60, 1, 230, '@end', 'generate_netcdf_file_for_C3_fraction').
annotation(61, 1, 234, '@begin', 'generate_netcdf_file_for_C4_fraction').
annotation(62, 1, 235, '@in', 'lon_variable').
annotation(63, 1, 236, '@in', 'lat_variable').
annotation(64, 1, 237, '@in', 'lon_bnds_variable').
annotation(65, 1, 238, '@in', 'lat_bnds_variable').
annotation(66, 1, 239, '@in', 'C4_Data').
annotation(67, 1, 240, '@out', 'C4_fraction_data').
annotation(68, 1, 240, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_C4Grass_RelaFrac_NA_v2.0.nc').
annotation(69, 1, 293, '@end', 'generate_netcdf_file_for_C4_fraction').
annotation(70, 1, 296, '@begin', 'generate_netcdf_file_for_Grass_fraction').
annotation(71, 1, 297, '@in', 'lon_variable').
annotation(72, 1, 298, '@in', 'lat_variable').
annotation(73, 1, 299, '@in', 'lon_bnds_variable').
annotation(74, 1, 300, '@in', 'lat_bnds_variable').
annotation(75, 1, 301, '@in', 'Grass_variable').
annotation(76, 1, 302, '@out', 'Grass_fraction_data').
annotation(77, 1, 302, '@uri', 'file:mstmip_SYNMAP_PRESENTVEG_Grass_Fraction_NA_v2.0.nc').
annotation(78, 1, 355, '@end', 'generate_netcdf_file_for_Grass_fraction').
annotation(79, 1, 358, '@end', 'main').

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
annotation_qualifies(28, 27).
annotation_qualifies(30, 29).
annotation_qualifies(34, 33).
annotation_qualifies(36, 35).
annotation_qualifies(40, 39).
annotation_qualifies(44, 43).
annotation_qualifies(46, 45).
annotation_qualifies(48, 47).
annotation_qualifies(50, 49).
annotation_qualifies(59, 58).
annotation_qualifies(68, 67).
annotation_qualifies(77, 76).
