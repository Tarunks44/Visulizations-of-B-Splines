% B-spline functions and their Fourier transforms animation
close all; clear all; clc;

% Define animation parameters
max_order = 5;  % Maximum order for animation
hold_time = 10; % Hold time in seconds

% Set up custom color scheme
colors = jet(max_order + 1);

% Time domain parameters
t = -10:0.01:10;
dt = t(2) - t(1);
N = length(t);

% Frequency domain parameters
fs = 1/dt;
f = (-N/2:N/2-1)*(fs/N);

% Create single figure with white background
fig = figure('Position', [100 100 1400 800], 'Color', 'w', 'NumberTitle', 'off', ...
    'Name', 'B-spline Analysis', 'Visible', 'on');

% Store all B-splines for overlay
all_bsplines = cell(max_order + 1, 1);
all_fourier = cell(max_order + 1, 1);

% Animation loop
for n = 0:max_order
    % Calculate B-spline of order n
    if n == 0
        bt = double(abs(t) <= 0.5);
    else
        b0 = double(abs(t) <= 0.5);
        bt = b0;
        for k = 1:n
            bt = conv(bt, b0, 'same')/sum(b0);
        end
    end
    
    % Store current B-spline
    all_bsplines{n+1} = bt;
    
    % Calculate Fourier transform
    Bt = fftshift(fft(fftshift(bt)));
    all_fourier{n+1} = abs(Bt)/max(abs(Bt));
    
    % Theoretical Fourier transform
    w = 2*pi*f;
    Bt_theory = (sin(w/2)./(w/2)).^(n+1);
    Bt_theory(isnan(Bt_theory)) = 1;
    
    % B-spline plot
    subplot(2,2,[1,2]);
    cla;
    hold on;
    % Plot previous B-splines with transparency
    for i = 1:n
        fill([t fliplr(t)], [all_bsplines{i} zeros(size(t))], ...
            colors(i,:), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    end
    % Plot current B-spline
    plot(t, bt, 'LineWidth', 3, 'Color', colors(n+1,:));
    fill([t fliplr(t)], [bt zeros(size(t))], colors(n+1,:), ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none');
    title(sprintf('B-spline β^{%d}(t)', n), 'FontSize', 16);
    xlabel('t', 'FontSize', 14);
    ylabel('β(t)', 'FontSize', 14);
    grid on;
    axis([-5 5 -0.1 1.2]);
    
    % Fourier transform magnitude plot
    subplot(2,2,3);
    cla;
    hold on;
    % Plot all previous Fourier transforms
    for i = 1:n
        h = plot(f, all_fourier{i});
        set(h, 'Color', [colors(i,:) 0.3], 'LineWidth', 1);
    end
    % Plot current Fourier transform
    plot(f, abs(Bt)/max(abs(Bt)), 'LineWidth', 3, 'Color', colors(n+1,:));
    plot(f, abs(Bt_theory), '--k', 'LineWidth', 1.5);
    title('Fourier Transform Magnitude', 'FontSize', 16);
    xlabel('Frequency (Hz)', 'FontSize', 14);
    ylabel('|B(f)|', 'FontSize', 14);
    legend('Numerical', 'Theoretical');
    grid on;
    axis([-2 2 -0.1 1.2]);
    
    % Phase plot
    subplot(2,2,4);
    cla;
    phase = angle(Bt);
    plot(f, phase, 'Color', colors(n+1,:), 'LineWidth', 2);
    title('Fourier Transform Phase', 'FontSize', 16);
    xlabel('Frequency (Hz)', 'FontSize', 14);
    ylabel('Phase (radians)', 'FontSize', 14);
    grid on;
    axis([-2 2 -pi pi]);
    
    % Add properties text box
    delete(findall(gcf,'type','annotation'));
    annotation('textbox', [0.02 0.02 0.3 0.1], 'String', {...
        sprintf('Order: %d', n), ...
        sprintf('Support Width: %.1f', sum(bt > 0.001)*dt), ...
        sprintf('Max Value: %.3f', max(bt)), ...
        sprintf('Integral: %.3f', sum(bt)*dt)}, ...
        'BackgroundColor', [1 1 1 0.7], ...
        'EdgeColor', 'k', 'FaceAlpha', 0.7);
    
    % Countdown timer
    for countdown = hold_time:-1:1
        sgtitle(sprintf('B-spline Analysis (Order = %d)\nNext order in: %d seconds', ...
            n, countdown), 'FontSize', 16);
        drawnow;
        pause(1);
    end
    
    if n < max_order
        clf(fig);
    end
end

% Add interactive controls
pan on;
zoom on;

% Final message
sgtitle(sprintf('B-spline Analysis Complete\nFinal Order: %d', max_order), 'FontSize', 16);