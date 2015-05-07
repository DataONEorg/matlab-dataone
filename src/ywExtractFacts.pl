
% FACT: extract_source(source_id, source_path).
extract_source(1, '_reader__').

% FACT: annotation(annotation_id, source_id, line_number, annotation_tag, annotation_value).
annotation(1, 1, 3, '@begin', 'main').
annotation(2, 1, 4, '@in', '“SPEI_01.nc”').
annotation(3, 1, 4, '@as', 'input_drough_variable').
annotation(4, 1, 5, '@in', '“TEM6_BG1_V1.0.1_Monthly_GPP.nc4”').
annotation(5, 1, 5, '@as', 'input_effect_variable').
annotation(6, 1, 6, '@out', '“RecoveryTime.png”').
annotation(7, 1, 6, '@as', 'output_recovery_time_figure').
annotation(8, 1, 7, '@out', '“DroughtVariable.png”').
annotation(9, 1, 7, '@as', 'output_drought_value_variable_figure').
annotation(10, 1, 8, '@out', '“PredroughtEffectVariable.png“').
annotation(11, 1, 8, '@as', 'output_predrought_effect_variable_figure').
annotation(12, 1, 9, '@out', '“DroughtNumber.png“').
annotation(13, 1, 9, '@as', 'output_drought_number_figure').
annotation(14, 1, 11, '@begin', 'fetch_drought_variable').
annotation(15, 1, 12, '@in', '“SPEI_01.nc”').
annotation(16, 1, 12, '@as', 'input_drough_variable').
annotation(17, 1, 13, '@out', 'dv').
annotation(18, 1, 13, '@as', 'drought_variable_1').
annotation(19, 1, 21, '@end', 'fetch_drought_variable').
annotation(20, 1, 23, '@begin', 'fetch_effect_variable').
annotation(21, 1, 24, '@in', '“TEM6_BG1_V1.0.1_Monthly_GPP.nc4”').
annotation(22, 1, 24, '@as', 'input_effect_variable').
annotation(23, 1, 25, '@out', 'ev').
annotation(24, 1, 25, '@as', 'effect_variable_1').
annotation(25, 1, 30, '@end', 'fetch_effect_variable').
annotation(26, 1, 32, '@begin', 'convert_effect_variable_units').
annotation(27, 1, 33, '@in', 'ev').
annotation(28, 1, 33, '@as', 'effect_variable_1').
annotation(29, 1, 34, '@out', 'ev').
annotation(30, 1, 34, '@as', 'effect_variable_2').
annotation(31, 1, 36, '@end', 'convert_effect_variable_units').
annotation(32, 1, 38, '@begin', 'create_land_water_mask').
annotation(33, 1, 39, '@in', 'ev').
annotation(34, 1, 39, '@as', 'effect_variable_2').
annotation(35, 1, 40, '@out', 'mask').
annotation(36, 1, 40, '@as', 'land_water_mask').
annotation(37, 1, 43, '@end', 'create_land_water_mask').
annotation(38, 1, 45, '@begin', 'init_data_variables').
annotation(39, 1, 46, '@in', 'mask').
annotation(40, 1, 46, '@as', 'land_water_mask').
annotation(41, 1, 47, '@out', 'predrought_effect').
annotation(42, 1, 47, '@as', 'predrought_effect_variable_1').
annotation(43, 1, 48, '@out', 'drought_value').
annotation(44, 1, 48, '@as', 'drought_value_variable_1').
annotation(45, 1, 49, '@out', 'recovery_time').
annotation(46, 1, 49, '@as', 'recovery_time_variable_1').
annotation(47, 1, 50, '@out', 'drought_number').
annotation(48, 1, 50, '@as', 'drought_number_variable_1').
annotation(49, 1, 55, '@end', 'init_data_variables').
annotation(50, 1, 57, '@begin', 'define_droughts').
annotation(51, 1, 58, '@out', 'thr').
annotation(52, 1, 58, '@as', 'sigma_dv_event').
annotation(53, 1, 59, '@out', 'len').
annotation(54, 1, 59, '@as', 'month_dv_length').
annotation(55, 1, 62, '@end', 'define_droughts').
annotation(56, 1, 64, '@begin', 'detrend_deseasonalize_effect_variable').
annotation(57, 1, 65, '@in', 'ev').
annotation(58, 1, 65, '@as', 'effect_variable_2').
annotation(59, 1, 66, '@out', 'ev').
annotation(60, 1, 66, '@as', 'effect_variable_3').
annotation(61, 1, 72, '@end', 'detrend_deseasonalize_effect_variable').
annotation(62, 1, 74, '@begin', 'calculate_data_variables').
annotation(63, 1, 75, '@in', 'dv').
annotation(64, 1, 75, '@as', 'drought_variable_1').
annotation(65, 1, 76, '@in', 'ev').
annotation(66, 1, 76, '@as', 'effect_variable_3').
annotation(67, 1, 77, '@in', 'thr').
annotation(68, 1, 77, '@as', 'sigma_dv_event').
annotation(69, 1, 78, '@in', 'len').
annotation(70, 1, 78, '@as', 'month_dv_length').
annotation(71, 1, 79, '@in', 'predrought_effect').
annotation(72, 1, 79, '@as', 'predrought_effect_variable_1').
annotation(73, 1, 80, '@in', 'drought_value').
annotation(74, 1, 80, '@as', 'drought_value_variable_1').
annotation(75, 1, 81, '@in', 'recovery_time').
annotation(76, 1, 81, '@as', 'recovery_time_variable_1').
annotation(77, 1, 82, '@in', 'drought_number').
annotation(78, 1, 82, '@as', 'drought_number_variable_1').
annotation(79, 1, 83, '@out', 'predrought_effect').
annotation(80, 1, 83, '@as', 'predrought_effect_variable_2').
annotation(81, 1, 84, '@out', 'drought_value').
annotation(82, 1, 84, '@as', 'drought_value_variable_2').
annotation(83, 1, 85, '@out', 'recovery_time').
annotation(84, 1, 85, '@as', 'recovery_time_variable_2').
annotation(85, 1, 86, '@out', 'drought_number').
annotation(86, 1, 86, '@as', 'drought_number_variable_2').
annotation(87, 1, 126, '@end', 'calculate_data_variables').
annotation(88, 1, 128, '@begin', 'export_recovery_time_figure').
annotation(89, 1, 129, '@in', 'recovery_time').
annotation(90, 1, 129, '@as', 'recovery_time_variable_2').
annotation(91, 1, 130, '@out', '‘RecoveryTime.png’').
annotation(92, 1, 130, '@as', 'output_recovery_time_figure').
annotation(93, 1, 152, '@end', 'export_recovery_time_figure').
annotation(94, 1, 154, '@begin', 'export_drought_value_variable_figure').
annotation(95, 1, 155, '@in', 'drought_value').
annotation(96, 1, 155, '@as', 'drought_value_variable_2').
annotation(97, 1, 156, '@out', '‘DroughtVariable.png’').
annotation(98, 1, 156, '@as', 'output_drought_value_variable_figure').
annotation(99, 1, 175, '@end', 'export_drought_value_variable_figure').
annotation(100, 1, 177, '@begin', 'export_predrought_effect_variable_figure').
annotation(101, 1, 178, '@in', 'predrought_effect').
annotation(102, 1, 178, '@as', 'predrought_effect_variable_2').
annotation(103, 1, 179, '@out', '“PredroughtEffectVariable.png“').
annotation(104, 1, 179, '@as', 'output_predrought_effect_variable_figure').
annotation(105, 1, 199, '@end', 'export_predrought_effect_variable_figure').
annotation(106, 1, 201, '@begin', 'export_drought_number_variable_figure').
annotation(107, 1, 202, '@in', 'drought_number').
annotation(108, 1, 202, '@as', 'drought_number_variable_2').
annotation(109, 1, 203, '@out', '“DroughtNumber.png“').
annotation(110, 1, 203, '@as', 'output_drought_number_figure').
annotation(111, 1, 222, '@end', 'export_drought_number_variable_figure').
annotation(112, 1, 226, '@end', 'main').

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
annotation_qualifies(22, 21).
annotation_qualifies(24, 23).
annotation_qualifies(28, 27).
annotation_qualifies(30, 29).
annotation_qualifies(34, 33).
annotation_qualifies(36, 35).
annotation_qualifies(40, 39).
annotation_qualifies(42, 41).
annotation_qualifies(44, 43).
annotation_qualifies(46, 45).
annotation_qualifies(48, 47).
annotation_qualifies(52, 51).
annotation_qualifies(54, 53).
annotation_qualifies(58, 57).
annotation_qualifies(60, 59).
annotation_qualifies(64, 63).
annotation_qualifies(66, 65).
annotation_qualifies(68, 67).
annotation_qualifies(70, 69).
annotation_qualifies(72, 71).
annotation_qualifies(74, 73).
annotation_qualifies(76, 75).
annotation_qualifies(78, 77).
annotation_qualifies(80, 79).
annotation_qualifies(82, 81).
annotation_qualifies(84, 83).
annotation_qualifies(86, 85).
annotation_qualifies(90, 89).
annotation_qualifies(92, 91).
annotation_qualifies(96, 95).
annotation_qualifies(98, 97).
annotation_qualifies(102, 101).
annotation_qualifies(104, 103).
annotation_qualifies(108, 107).
annotation_qualifies(110, 109).
