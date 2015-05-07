
% FACT: program(program_id, program_name, begin_annotation_id, end_annotation_id).
program(1, 'main', 1, 112).
program(2, 'fetch_drought_variable', 14, 19).
program(3, 'fetch_effect_variable', 20, 25).
program(4, 'convert_effect_variable_units', 26, 31).
program(5, 'create_land_water_mask', 32, 37).
program(6, 'init_data_variables', 38, 49).
program(7, 'define_droughts', 50, 55).
program(8, 'detrend_deseasonalize_effect_variable', 56, 61).
program(9, 'calculate_data_variables', 62, 87).
program(10, 'export_recovery_time_figure', 88, 93).
program(11, 'export_drought_value_variable_figure', 94, 99).
program(12, 'export_predrought_effect_variable_figure', 100, 105).
program(13, 'export_drought_number_variable_figure', 106, 111).

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
has_sub_program(1, 10).
has_sub_program(1, 11).
has_sub_program(1, 12).
has_sub_program(1, 13).

% FACT: port(port_id, port_type, port_name, port_annotation_id).
port(1, 'in', '“SPEI_01.nc”', 2).
port(2, 'in', '“TEM6_BG1_V1.0.1_Monthly_GPP.nc4”', 4).
port(3, 'out', '“RecoveryTime.png”', 6).
port(4, 'out', '“DroughtVariable.png”', 8).
port(5, 'out', '“PredroughtEffectVariable.png“', 10).
port(6, 'out', '“DroughtNumber.png“', 12).
port(7, 'in', '“SPEI_01.nc”', 15).
port(8, 'out', 'dv', 17).
port(9, 'in', '“TEM6_BG1_V1.0.1_Monthly_GPP.nc4”', 21).
port(10, 'out', 'ev', 23).
port(11, 'in', 'ev', 27).
port(12, 'out', 'ev', 29).
port(13, 'in', 'ev', 33).
port(14, 'out', 'mask', 35).
port(15, 'in', 'mask', 39).
port(16, 'out', 'predrought_effect', 41).
port(17, 'out', 'drought_value', 43).
port(18, 'out', 'recovery_time', 45).
port(19, 'out', 'drought_number', 47).
port(20, 'out', 'thr', 51).
port(21, 'out', 'len', 53).
port(22, 'in', 'ev', 57).
port(23, 'out', 'ev', 59).
port(24, 'in', 'dv', 63).
port(25, 'in', 'ev', 65).
port(26, 'in', 'thr', 67).
port(27, 'in', 'len', 69).
port(28, 'in', 'predrought_effect', 71).
port(29, 'in', 'drought_value', 73).
port(30, 'in', 'recovery_time', 75).
port(31, 'in', 'drought_number', 77).
port(32, 'out', 'predrought_effect', 79).
port(33, 'out', 'drought_value', 81).
port(34, 'out', 'recovery_time', 83).
port(35, 'out', 'drought_number', 85).
port(36, 'in', 'recovery_time', 89).
port(37, 'out', '‘RecoveryTime.png’', 91).
port(38, 'in', 'drought_value', 95).
port(39, 'out', '‘DroughtVariable.png’', 97).
port(40, 'in', 'predrought_effect', 101).
port(41, 'out', '“PredroughtEffectVariable.png“', 103).
port(42, 'in', 'drought_number', 107).
port(43, 'out', '“DroughtNumber.png“', 109).

% FACT: port_alias(port_id, alias).
port_alias(1, 'input_drough_variable').
port_alias(2, 'input_effect_variable').
port_alias(3, 'output_recovery_time_figure').
port_alias(4, 'output_drought_value_variable_figure').
port_alias(5, 'output_predrought_effect_variable_figure').
port_alias(6, 'output_drought_number_figure').
port_alias(7, 'input_drough_variable').
port_alias(8, 'drought_variable_1').
port_alias(9, 'input_effect_variable').
port_alias(10, 'effect_variable_1').
port_alias(11, 'effect_variable_1').
port_alias(12, 'effect_variable_2').
port_alias(13, 'effect_variable_2').
port_alias(14, 'land_water_mask').
port_alias(15, 'land_water_mask').
port_alias(16, 'predrought_effect_variable_1').
port_alias(17, 'drought_value_variable_1').
port_alias(18, 'recovery_time_variable_1').
port_alias(19, 'drought_number_variable_1').
port_alias(20, 'sigma_dv_event').
port_alias(21, 'month_dv_length').
port_alias(22, 'effect_variable_2').
port_alias(23, 'effect_variable_3').
port_alias(24, 'drought_variable_1').
port_alias(25, 'effect_variable_3').
port_alias(26, 'sigma_dv_event').
port_alias(27, 'month_dv_length').
port_alias(28, 'predrought_effect_variable_1').
port_alias(29, 'drought_value_variable_1').
port_alias(30, 'recovery_time_variable_1').
port_alias(31, 'drought_number_variable_1').
port_alias(32, 'predrought_effect_variable_2').
port_alias(33, 'drought_value_variable_2').
port_alias(34, 'recovery_time_variable_2').
port_alias(35, 'drought_number_variable_2').
port_alias(36, 'recovery_time_variable_2').
port_alias(37, 'output_recovery_time_figure').
port_alias(38, 'drought_value_variable_2').
port_alias(39, 'output_drought_value_variable_figure').
port_alias(40, 'predrought_effect_variable_2').
port_alias(41, 'output_predrought_effect_variable_figure').
port_alias(42, 'drought_number_variable_2').
port_alias(43, 'output_drought_number_figure').

% FACT: port_uri(port_id, uri).

% FACT: has_in_port(block_id, port_id).
has_in_port(1, 1).
has_in_port(1, 2).
has_in_port(2, 7).
has_in_port(3, 9).
has_in_port(4, 11).
has_in_port(5, 13).
has_in_port(6, 15).
has_in_port(8, 22).
has_in_port(9, 24).
has_in_port(9, 25).
has_in_port(9, 26).
has_in_port(9, 27).
has_in_port(9, 28).
has_in_port(9, 29).
has_in_port(9, 30).
has_in_port(9, 31).
has_in_port(10, 36).
has_in_port(11, 38).
has_in_port(12, 40).
has_in_port(13, 42).

% FACT: has_out_port(block_id, port_id).
has_out_port(1, 3).
has_out_port(1, 4).
has_out_port(1, 5).
has_out_port(1, 6).
has_out_port(2, 8).
has_out_port(3, 10).
has_out_port(4, 12).
has_out_port(5, 14).
has_out_port(6, 16).
has_out_port(6, 17).
has_out_port(6, 18).
has_out_port(6, 19).
has_out_port(7, 20).
has_out_port(7, 21).
has_out_port(8, 23).
has_out_port(9, 32).
has_out_port(9, 33).
has_out_port(9, 34).
has_out_port(9, 35).
has_out_port(10, 37).
has_out_port(11, 39).
has_out_port(12, 41).
has_out_port(13, 43).

% FACT: channel(channel_id, binding).
channel(1, 'output_recovery_time_figure').
channel(2, 'output_drought_value_variable_figure').
channel(3, 'output_predrought_effect_variable_figure').
channel(4, 'output_drought_number_figure').
channel(5, 'input_drough_variable').
channel(6, 'input_effect_variable').
channel(7, 'effect_variable_1').
channel(8, 'effect_variable_2').
channel(9, 'effect_variable_2').
channel(10, 'land_water_mask').
channel(11, 'drought_variable_1').
channel(12, 'effect_variable_3').
channel(13, 'sigma_dv_event').
channel(14, 'month_dv_length').
channel(15, 'predrought_effect_variable_1').
channel(16, 'drought_value_variable_1').
channel(17, 'recovery_time_variable_1').
channel(18, 'drought_number_variable_1').
channel(19, 'recovery_time_variable_2').
channel(20, 'drought_value_variable_2').
channel(21, 'predrought_effect_variable_2').
channel(22, 'drought_number_variable_2').

% FACT: port_connects_to_channel(port_id, channel_id).
port_connects_to_channel(37, 1).
port_connects_to_channel(3, 1).
port_connects_to_channel(39, 2).
port_connects_to_channel(4, 2).
port_connects_to_channel(41, 3).
port_connects_to_channel(5, 3).
port_connects_to_channel(43, 4).
port_connects_to_channel(6, 4).
port_connects_to_channel(1, 5).
port_connects_to_channel(7, 5).
port_connects_to_channel(2, 6).
port_connects_to_channel(9, 6).
port_connects_to_channel(10, 7).
port_connects_to_channel(11, 7).
port_connects_to_channel(12, 8).
port_connects_to_channel(13, 8).
port_connects_to_channel(12, 9).
port_connects_to_channel(22, 9).
port_connects_to_channel(14, 10).
port_connects_to_channel(15, 10).
port_connects_to_channel(8, 11).
port_connects_to_channel(24, 11).
port_connects_to_channel(23, 12).
port_connects_to_channel(25, 12).
port_connects_to_channel(20, 13).
port_connects_to_channel(26, 13).
port_connects_to_channel(21, 14).
port_connects_to_channel(27, 14).
port_connects_to_channel(16, 15).
port_connects_to_channel(28, 15).
port_connects_to_channel(17, 16).
port_connects_to_channel(29, 16).
port_connects_to_channel(18, 17).
port_connects_to_channel(30, 17).
port_connects_to_channel(19, 18).
port_connects_to_channel(31, 18).
port_connects_to_channel(34, 19).
port_connects_to_channel(36, 19).
port_connects_to_channel(33, 20).
port_connects_to_channel(38, 20).
port_connects_to_channel(32, 21).
port_connects_to_channel(40, 21).
port_connects_to_channel(35, 22).
port_connects_to_channel(42, 22).

% FACT: uri_variable(uri_variable_id, variable_name, port_id).
