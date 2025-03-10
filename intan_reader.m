% ##############################################
% #################INTAN READER#################
% ##############################################

% Version 1.0, 20 February 2025
% Made by Yeonseo Choo (https://github.com/ChooYeonseo)

function intan_reader(name, chnn, save_dir, processed_dir)

% ##############################################
% #######Step0: Parameter Initialization #######
% ##############################################
% The user must initialize all required parameters below to ensure proper 
% execution. Failure to do so may result in program crashes due to 
% incorrect initialization. Please refer to the descriptions provided and 
% enter accurate values that match your data. The annotated values serve as 
% general recommendations based on typical datasets.
create_file(save_dir);

% ##############################################
% ############Step1: RHD File Loader############
% ##############################################
% Reading Intan RHD files. **No need of modification**.
[t_amplifier, amplifier_data] = Intan_RHD2000_file_reader;

% ##############################################
% ##########Step2: Data Preprocessing ##########
% ##############################################
% Preprocessing read RHD data. **No need of modification**.

data.name = name;
data.x = transpose(t_amplifier);
fs = length(data.x)/(data.x(end)-data.x(1));

for i = 1:chnn
    temp_datay = transpose(amplifier_data(i,:));
    data.y=temp_datay; 
    tmp_filename = fullfile(save_dir, sprintf('E_%d.mat', i));
    tmp_copy = fullfile(processed_dir, sprintf('E_%d.mat', i));
    save(tmp_filename, 'data');
    save(tmp_copy, 'data');
end 

fprintf(1, 'finish converting\n');
figure;
str1 = repmat({'E_'}, 1, chnn);
ch1 = num2cell(1:chnn);
save_as_TIF(str1, ch1, 'total_img', 1, save_dir)
end

function create_file(save_dir)
    % Ensure the directory exists; if not, create it
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
end