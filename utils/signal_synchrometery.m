% ##############################################
% #############SIGNAL SYNCHROMETERY#############
% ##############################################

classdef signal_synchrometery
    methods
        % Define parameters
        function correlation_matrix(obj, channel_list, save_dir, sampling_rate, t_start, t_end)
            clf;  % Clears the current figure (Do not delete this line of code.)
            % Load and process multiple .mat files containing signal data
            mat_files = [];
            for i = channel_list
                tmp_dir = fullfile(save_dir, sprintf('E_%d.mat', i));
                mat_files = [mat_files, tmp_dir];
            end
            N = length(mat_files);
            data_list = cell(1, N);

            for i = 1:N
                matData = load(mat_files{i});
                data_list{i} = matData.data; % Adjust field name if necessary
            end
            
            num_channels = length(channel_list);

            % Compute correlation matrix
            corr_matrix = zeros(num_channels, num_channels);

            for i = 1:num_channels
                for j = 1:num_channels
                    % Compute correlation coefficient at zero lag
                    [t, sig1] = obj.get_time_limited_data(data_list{i}, t_start, t_end);
                    [t, sig2] = obj.get_time_limited_data(data_list{j}, t_start, t_end);
                    corr_values = corr(sig1, sig2);
                    corr_matrix(i, j) = corr_values;
                end
            end

            % Plot the correlation matrix as a heatmap
            figure;
            imagesc(corr_matrix);
            colorbar;
            caxis([0 1]); % Set color limits from -1 to 1 (correlation range)
            xticks(1:num_channels);
            yticks(1:num_channels);
            xticklabels(string(channel_list));
            yticklabels(string(channel_list));
            xlabel('Channel Number');
            ylabel('Channel Number');
            title('N × N Cross-Correlation Matrix');
            colormap(jet); % Choose a colormap
        end

            function simple_comparison(obj, channel_list, save_dir, sampling_rate, t_start, t_end)
                clf;  % Clears the current figure (Do not delete this line of code.)
                % Load and process multiple .mat files containing signal data
                mat_files = [];
                for i = channel_list
                    tmp_dir = fullfile(save_dir, sprintf('E_%d.mat', i));
                    mat_files = [mat_files, tmp_dir];
                end
                N = length(mat_files);
                data_list = cell(1, N);

                for i = 1:N
                    matData = load(mat_files{i});
                    data_list{i} = matData.data; % Adjust field name if necessary
                end

                figure;
                for i = 1:N
                    for j = i:N
                        subplot(N, N, (i - 1) * N + j);
                        title_name = sprintf("Ch%d vs Ch%d", channel_list(i), channel_list(j));

                        [t, sig1] = obj.get_time_limited_data(data_list{i}, t_start, t_end);
                        [t, sig2] = obj.get_time_limited_data(data_list{j}, t_start, t_end);

                        % Compute correlation
                        window_length = sampling_rate/10;
                        [corr_values, t_corr] = compute_time_correlation(obj, sig1, sig2, t, window_length, title_name);
                        plot(t_corr, corr_values);
                        title(title_name);
                        ytickformat('%.1f')
                        xlim([t_corr(1), t_corr(end)]);
                        ylim([-1.5, 1.5]);
                        xlabel('Time (s)');
                        ylabel('Correlation');
                    end
                end
                sgtitle('Time vs Correlation of Signals');
            end

            function [t, signal] = get_time_limited_data(obj, data, t_start, t_end)
                % Extracts time-limited portion of the data
                time = data.x;
                signal = data.y;
                mask = (time >= t_start) & (time <= t_end);
                t = time(mask);
                signal = signal(mask);
            end

            function [corr_values, t_corr] = compute_time_correlation(obj, sig1, sig2, t, window_size, title_name)
                % Computes time-varying correlation between two signals using a sliding window

                % Ensure both signals are column vectors
                % sig1 = (sig1(:) - mean(sig1(:))) / std(sig1(:));
                % sig2 = (sig2(:) - mean(sig2(:))) / std(sig2(:));

                % Get signal length
                N = length(sig1);

                % Define output size (correlation computed at each window position)
                corr_values = zeros(N - window_size + 1, 1);

                % Compute correlation in a sliding window
                for i = 1:length(corr_values)
                    segment1 = sig1(i:i+window_size-1);
                    segment2 = sig2(i:i+window_size-1);
                    corr_values(i) = corr(segment1, segment2);  % Pearson correlation
                end

                % Align time vector to match correlation values
                t_corr = t(ceil(window_size / 2) : end - floor(window_size / 2));

                % Debugging output
                fprintf('Computed correlation of %s: mean = %g, std = %g\n', title_name, mean(corr_values), std(corr_values));
            end
        end
    end
