% Load the .mat file
data = load("C:\Users\user\sean\Multimodal-Brain-Signal-Analysis\rawdata\electrochemistry\250220_probes\GluIvv3B_invitro.mat"); % Replace 'your_file.mat' with your filename
struct_field = fieldnames(data);
data_matrix = data.(struct_field{1});
% Assuming the data has variables 'time' and 'current'
time = data_matrix(:,1);
current = data_matrix(:,2) * 1000; % Current variable in amperes

% Plot the time-current data
figure;
plot(time, current, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
xlim([270, 5400]);
ylabel('Current (nA)');
title('Time vs Current');
grid on;
hold on;

% Define the list of time intervals

time_intervals = [270,276;
1620, 1680;
1850, 1975;
2400, 2480;
2750, 2950;
3400, 3650;
4400, 4850;
5200, 5400;];

% Define the concentration labels
concentration = {'baseline', '2.5uM', '5uM', '10uM', '20uM', '40uM', '80uM', '160uM'};

% Define a set of colors for the horizontal lines
colors = lines(size(time_intervals, 1)); % Generates a colormap with enough distinct colors

% Initialize a cell array to hold legend entries and a vector to hold mean currents
legend_entries = {'Current'}; % First entry for the main plot
mean_currents = zeros(size(time_intervals, 1), 1); % Vector to store the mean currents

% Call the function to draw horizontal lines and collect mean currents
for i = 1:size(time_intervals, 1)
    avg_label = draw_average_line(time, current, time_intervals(i, :), concentration{i}, colors(i, :));
    legend_entries{end+1} = avg_label; % Add the average label to the legend
    
    % Store the mean current for regression plot
    mean_currents(i) = mean(current(time >= time_intervals(i, 1) & time <= time_intervals(i, 2)));
end

% Set the legend
legend(legend_entries, 'Location', 'best');
hold off;

% Linear Regression: Concentration vs. Mean Currents
% Convert concentration labels to numeric values for regression
concentration_numeric = [0, 2.5, 5, 10, 20, 40, 80, 160]; % Numeric representation of concentrations

% Perform linear regression
[p, S] = polyfit(concentration_numeric(2:end), mean_currents(2:end), 1); % Linear fit (degree 1)

% Calculate R-squared value (single value for the entire regression)
y_fit = polyval(p, concentration_numeric(2:end)); % Fitted values from regression
SS_tot = sum((mean_currents(2:end) - mean(mean_currents(2:end))).^2); % Total sum of squares
SS_res = sum((mean_currents(2:end) - y_fit.').^2); % Residual sum of squares
R2 = 1 - (SS_res / SS_tot); % R-squared value (single scalar)


% Plot the linear regression
figure;
plot(concentration_numeric(2:end), mean_currents(2:end), 'bo', 'MarkerFaceColor', 'b'); % Plot original data points
hold on;
plot(concentration_numeric(2:end), y_fit, 'r-', 'LineWidth', 2); % Plot linear regression line
xlabel('Concentration (uM)');
ylabel('Mean Current (nA)');
title('Linearity Check'); % Simple title
grid on;

% Display R-squared value in the plot as a single text
text(0.1, max(mean_currents)*0.9, sprintf('R^2 = %.4f', R2), 'FontSize', 12, 'Color', 'red', 'FontWeight', 'bold');


% Function to draw horizontal line for a given time interval
function avg_label = draw_average_line(time, current, time_interval, name, color)
    % Extract the data within the time interval
    indices = time >= time_interval(1) & time <= time_interval(2);
    current_filtered = current(indices);

    % Calculate the average current in the interval
    average_current = mean(current_filtered);

    % Plot the horizontal line for the average current
    yline(average_current, '--', 'Color', color, 'LineWidth', 1.5);

    % Return the label for the legend
    avg_label = sprintf('%-10s: %.3f nA', name, average_current);
end
