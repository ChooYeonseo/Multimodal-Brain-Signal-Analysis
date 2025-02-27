function filtered_data = average_smoother(data, Lf, Hf)
% LOW_PASS_FILTER Applies a low-pass and high-pass filter, with optional smoothing
%
% Inputs:
%   - data: Structure with fields:
%       - data.name (string)
%       - data.x (n x 1 time list)
%       - data.y (8 x n signal matrix, one row per channel)
%   - selectedChannel: Channel to apply additional smoothing
%   - save_dir: Directory to save filtered signals
%
% Output:
%   - filtered_data: Structure with filtered data
% Extract time vector and calculate sampling frequency
data.x = transpose(data.x);
fs = length(data.x) / (data.x(end) - data.x(1));

% Define filter parameters
Hz1 = Lf;  % Low-pass filter cutoff frequency
Hz2 = Hf;  % High-pass filter cutoff frequency
windowSize = round(fs * 0.05);  % Moving average window (50 ms)

% Preallocate output structure
filtered_data = data;

% Process each channel separately

filtered_data.y = lowpass(data.y, Hz1, fs);
filtered_data.y = highpass(filtered_data.y, Hz2, fs);
filtered_data.y = smoothdata(filtered_data.y, 'movmean', windowSize);
end