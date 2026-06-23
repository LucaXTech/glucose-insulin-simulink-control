%% Baseline comparison: healthy vs type 2 profile
% Compares healthy and type 2 profiles under the same meal input with
% external insulin/control disabled.
%
% This is the most readable baseline figure for the public portfolio,
% because the uncontrolled type 1 profile is intentionally pathological and
% can dominate the glucose axis.

clear; clc; close all;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'model'));
addpath(fullfile(projectRoot, 'scripts'));

modelName = 'bergman_model';

% Start from a clean in-memory model to avoid temporary probe blocks left by
% previous test runs.
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
load_system(fullfile(projectRoot, 'model', [modelName '.slx']));

stopTime = '600';
mealIntensity = 0.2;
insulinMode = 0;  % 0 = no external insulin / no controller

scenarios = struct( ...
    'label', {'Healthy', 'Type 2'}, ...
    'patient', {1, 3});

results = struct([]);

for k = 1:numel(scenarios)
    configure_bergman_model(modelName, scenarios(k).patient, insulinMode, mealIntensity);
    simOut = sim(modelName, 'StopTime', stopTime, 'ReturnWorkspaceOutputs', 'on');

    [tG, G] = extract_sim_signal(simOut, 'G_out');
    [tI, I] = extract_sim_signal(simOut, 'I_out');
    [tX, X] = extract_sim_signal(simOut, 'X_out');

    results(k).label = scenarios(k).label;
    results(k).tG = tG;
    results(k).G = G;
    results(k).tI = tI;
    results(k).I = I;
    results(k).tX = tX;
    results(k).X = X;

    fprintf('\n%s baseline\n', scenarios(k).label);
    fprintf('  Peak glucose: %.2f mg/dL\n', max(G));
    fprintf('  Minimum glucose: %.2f mg/dL\n', min(G));
    fprintf('  Mean glucose: %.2f mg/dL\n', mean(G));
end

figure('Name', 'Healthy vs Type 2 baseline comparison', 'NumberTitle', 'off');

subplot(3, 1, 1);
hold on;
for k = 1:numel(results)
    plot(results(k).tG, results(k).G, 'LineWidth', 1.5);
end
ylabel('G(t) [mg/dL]');
title('Blood glucose response');
legend({results.label}, 'Location', 'best');
grid on;

subplot(3, 1, 2);
hold on;
for k = 1:numel(results)
    plot(results(k).tI, results(k).I, 'LineWidth', 1.5);
end
ylabel('I(t) [\muU/mL]');
title('Plasma insulin response');
legend({results.label}, 'Location', 'best');
grid on;

subplot(3, 1, 3);
hold on;
for k = 1:numel(results)
    plot(results(k).tX, results(k).X, 'LineWidth', 1.5);
end
xlabel('Time [min]');
ylabel('X(t)');
title('Delayed insulin action');
legend({results.label}, 'Location', 'best');
grid on;

sgtitle('Baseline comparison with controller disabled');

figuresDir = fullfile(projectRoot, 'figures');
if ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end
saveas(gcf, fullfile(figuresDir, 'healthy_vs_type2_baseline.png'));
