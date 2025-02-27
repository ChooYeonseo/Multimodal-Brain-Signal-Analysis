function filtered_data = low_pass_filter(data, sample_freq, cutoff_freq)
    % LOW_PASS_FUNCTION Applies a low-pass filter to the signal in a structured data
    %
    % Inputs:
    %   - data: Structure with fields:
    %       - data.name (string)
    %       - data.x (n x 1 time list)
    %       - data.y (n x 1 signal list)
    %   - sample_freq: Sampling frequency (Hz)
    %   - cutoff_freq: Cutoff frequency for the low-pass filter (Hz)
    %
    % Output:
    %   - filtered_data: Structure with the same fields as input,
    %     but with the filtered y values

    % Ensure data.y is a column vector
    y = data.y(:);
    
    % Design a Butterworth low-pass filter
    order = 3; % Filter order
    Wn = cutoff_freq / (sample_freq / 2); % Normalized cutoff frequency
    [b, a] = butter(order, Wn, 'low');

    % Apply zero-phase filtering to avoid phase distortion
    filtered_y = filtfilt(b, a, y);

    % Create output structure with filtered signal
    filtered_data = data;
    filtered_data.y = filtered_y;
end
