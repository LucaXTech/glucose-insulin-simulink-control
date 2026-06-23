%% Analyze glucose control response
% Run a simulation first and keep the simulation output variable as `simOut`
% or `out` in the MATLAB workspace.
%
% For the public portfolio, this script analyzes model-level outputs and,
% when available, the applied exogenous insulin input logged as
% I_ext_applied. This is preferred over controller-internal signals.

if exist('simOut', 'var')
    simulationOutput = simOut;
elseif exist('out', 'var')
    simulationOutput = out;
else
    error('Simulation output variable not found. Run the model first and keep the output as simOut or out.');
end

%% Signal extraction
[tG, G] = extract_sim_signal(simulationOutput, 'G_out');
[~, I] = extract_sim_signal(simulationOutput, 'I_out');

try
    [~, I_ext_applied] = extract_logged_signal(simulationOutput, 'I_ext_applied');
catch
    warning('I_ext_applied was not found in logsout. Returning NaN for external insulin metrics.');
    I_ext_applied = nan(size(G));
end

t = tG;
glucoseTarget = 100;
glucoseDeviation = G - glucoseTarget;

%% Numerical analysis
G0 = G(1);
[G_max, idxMax] = max(G);
[G_min, idxMinLocal] = min(G(idxMax:end));
idxMin = idxMax + idxMinLocal - 1;
G_min_time = t(idxMin);
peak_time = t(idxMax);
descent_time = G_min_time - peak_time;

I_ext_max = max(I_ext_applied);
I_ext_mean = mean(I_ext_applied, 'omitnan');

mean_abs_deviation = mean(abs(glucoseDeviation));

%% Text report
fprintf('===== GLUCOSE CONTROL ANALYSIS =====\n');
fprintf('Initial glucose: %.1f mg/dL\n', G0);
fprintf('Glucose peak: %.1f mg/dL at t = %.1f min\n', G_max, peak_time);
fprintf('Post-peak minimum: %.1f mg/dL at t = %.1f min (delta = %.1f)\n', ...
    G_min, G_min_time, G_max - G_min);
fprintf('Descent time after peak: %.1f min\n', descent_time);
fprintf('Peak applied external insulin input: %.2f\n', I_ext_max);
fprintf('Mean applied external insulin input: %.2f\n', I_ext_mean);
fprintf('Mean absolute glucose deviation from %.0f mg/dL: %.2f mg/dL\n', ...
    glucoseTarget, mean_abs_deviation);
fprintf('====================================\n\n');

%% Dynamic plot
figure('Name', 'Glucose control analysis', 'NumberTitle', 'off');

subplot(3, 1, 1)
plot(t, G, 'LineWidth', 1.5); hold on;
plot(t(idxMax), G_max, 'o');
plot(G_min_time, G_min, 'o');
ylabel('G(t) [mg/dL]');
title('Glucose response');
grid on;

subplot(3, 1, 2)
plot(t, I_ext_applied, 'LineWidth', 1.5);
ylabel('I_{ext}(t)');
title('Applied exogenous insulin input');
grid on;

subplot(3, 1, 3)
plot(t, I, 'LineWidth', 1.5);
ylabel('I(t) [\muU/mL]');
xlabel('Time [min]');
title('Plasma insulin');
grid on;

sgtitle('Glucose control analysis - Simulink');
