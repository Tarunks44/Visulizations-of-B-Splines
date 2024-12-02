% Comprehensive Spline Wavelet Analysis
clear all; close all; clc;

% Generate test signal
t = 0:0.001:1;
signal = sin(2*pi*10*t) + 0.5*sin(2*pi*50*t) + 0.2*sin(2*pi*100*t);

% Analysis parameters
decomposition_level = 3;
spline_orders = 1:4;
num_orders = length(spline_orders);

% Initialize MSE storage
mse_all = zeros(decomposition_level, num_orders);

% Create figures for visualization
figure('Position', [50 50 1200 800], 'Name', 'Original Signal');
plot(t, signal, 'b', 'LineWidth', 1.5);
title('Input Signal', 'FontSize', 14);
xlabel('Time');
ylabel('Amplitude');
grid on;

% Create a new figure for each spline order
for current_order = spline_orders
    % Perform decomposition
    [approx, details, mse] = spline_wavelet_decomp(signal, decomposition_level, current_order);
    
    % Store MSE values
    mse_all(:, current_order) = mse;
    
    % Create figure for this spline order
    figure('Position', [50+current_order*30 50+current_order*30 1200 800], ...
           'Name', sprintf('Spline Order %d Analysis', current_order));
    
    % Number of subplots needed
    total_plots = decomposition_level * 2 + 1;
    
    % Plot original signal
    subplot(total_plots, 1, 1);
    plot(t, signal, 'b', 'LineWidth', 1.5);
    title(sprintf('Original Signal (Spline Order %d)', current_order), 'FontSize', 12);
    xlabel('Time');
    ylabel('Amplitude');
    grid on;
    
    % Plot approximation coefficients
    for level = 1:decomposition_level
        subplot(total_plots, 1, level*2);
        t_approx = linspace(0, 1, length(approx{level}));
        plot(t_approx, approx{level}, 'r', 'LineWidth', 1.5);
        title(sprintf('Level %d Approximation Coefficients', level), 'FontSize', 12);
        xlabel('Time');
        ylabel('Amplitude');
        grid on;
        
        % Plot detail coefficients
        subplot(total_plots, 1, level*2+1);
        t_detail = linspace(0, 1, length(details{level}));
        plot(t_detail, details{level}, 'g', 'LineWidth', 1.5);
        title(sprintf('Level %d Detail Coefficients', level), 'FontSize', 12);
        xlabel('Time');
        ylabel('Amplitude');
        grid on;
    end
    
    % Add information text box
    info_text = {...
        sprintf('SPLINE ORDER %d ANALYSIS', current_order), ...
        '', ...
        'Characteristics:', ...
        sprintf('• Number of filter coefficients: %d', length(bspline_filter(current_order))), ...
        sprintf('• Average MSE: %.6f', mean(mse)), ...
        sprintf('• Support width: %d', 2^decomposition_level), ...
        '', ...
        'Level-wise MSE:', ...
        sprintf('Level 1: %.6f', mse(1)), ...
        sprintf('Level 2: %.6f', mse(2)), ...
        sprintf('Level 3: %.6f', mse(3))};
    
    annotation('textbox', [0.02 0.02 0.25 0.15], ...
        'String', info_text, ...
        'EdgeColor', 'k', ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'on', ...
        'FontSize', 9);
end

% Create summary figure
figure('Position', [100 100 800 600], 'Name', 'MSE Comparison');
bar(1:decomposition_level, mse_all);
title('MSE Comparison Across Levels and Orders', 'FontSize', 14);
xlabel('Decomposition Level');
ylabel('Mean Squared Error');
legend('Order 1', 'Order 2', 'Order 3', 'Order 4');
grid on;

% Add overall performance text box
overall_mse = mean(mse_all, 1);
performance_text = {'OVERALL PERFORMANCE (Average MSE):'};
for i = 1:num_orders
    performance_text{end+1} = sprintf('Order %d: %.6f', i, overall_mse(i));
end
annotation('textbox', [0.02 0.02 0.25 0.1], ...
    'String', performance_text, ...
    'EdgeColor', 'k', ...
    'BackgroundColor', 'w', ...
    'FitBoxToText', 'on', ...
    'FontSize', 9);