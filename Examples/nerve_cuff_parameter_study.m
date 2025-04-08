clc; clear all; 

if ispc
cd('..\');
else
cd('../');
end


level_potentials=3:30;

%% Run the algorithm

coil_layouts(numel(level_potentials)).out=[]; %Inititialize the output struct
coil_ind=1;
for level=level_potentials % run the algorithm for different numbers of potential levels

coil_layouts(coil_ind).out=CoilGen(...
    'field_shape_function','0.05',... % definition of the target field
    'coil_mesh_file','nerve_cuff_big.stl', ...     'target_mesh_file','none', ... 
    'secondary_target_mesh_file','none', ...
    'sf_source_file','none', ...
    'target_region_radius',0.000, ...  % in meter
    'target_region_resolution',10,... % number of target points in one dimension
    'use_only_target_mesh_verts',false, ...
    'surface_is_cylinder_flag',true, ...
    'skip_postprocessing',false,...
    'skip_inductance_calculation',false,...
    'make_cylndrical_pcb',false,...
    'force_cut_selection',{'low'},...
    'level_set_method','primary',... %Specify one of the three ways the level sets are calculated: "primary","combined", or "independent"
    'interconnection_method','regular',...
    'group_interconnection_method', 'straight',...
    'sf_opt_method','tikkonov',...
    'levels',level, ... % the number of potential steps that determines the later number of windings (Stream function discretization)
    'tikonov_reg_factor',6,... % PUT RESULT FROM PYTHON SIM HERE 
    'pot_offset_factor',0.1, ... % a potential offset value for the minimal and maximal contour potential ; must be between 0 and 1
    'interconnection_cut_width',0.005, ... % the width for the interconnections are interconnected; in meters
    'min_loop_signifcance', 1,... % min required loop contriubtion to target in percent
    'normal_shift_length',0.001, ... % the length for which overlapping return paths will be shifted along the surface normals; in meter
    'iteration_num_mesh_refinement',0, ... % the number of refinements for the mesh;
    'conductor_cross_section_width',0.05,...
    'geometry_source_path', '/Users/Susanna/Documents/CoilGen/Geometry_Data',...
    'output_directory', '/Users/Susanna/Documents/CoilGen/output'); 


coil_ind=coil_ind+1;

end



%% Plot results
close all;

coil_name='coil';

if ispc
addpath(strcat(pwd,'\','plotting'));
else
addpath(strcat(pwd,'/','plotting'));
end
%Chose a even leveled solution for plotting
solutions_to_plot=find(arrayfun(@(x) ~isempty(coil_layouts(x).out),1:numel(coil_layouts)));
single_ind_to_plot= find_even_leveled_solution(coil_layouts);
plot_error_different_solutions(coil_layouts,solutions_to_plot,coil_name);
plot_2D_contours_with_sf(coil_layouts,single_ind_to_plot,coil_name);
%plot_groups_and_interconnections(coil_layouts,single_ind_to_plot,coil_name);
plot_coil_parameters(coil_layouts,coil_name);
plot_coil_track_with_resulting_bfield(coil_layouts,single_ind_to_plot,coil_name);
plot_various_error_metrics(coil_layouts,single_ind_to_plot,coil_name);
plot_resulting_gradient(coil_layouts,single_ind_to_plot,coil_name);
rmpath('plotting');