%% Control strategy comparison for the type 2 diabetic profile
% Compares no external insulin, PID control and fuzzy control under the same
% meal input for the type 2 diabetic profile.
%
% Important modelling note:
% The signal plotted as I_ext_applied is logged after the model-level insulin
% selector and after the subsystem that disables external insulin for
% non-pathological profiles. Therefore it represents the selected exogenous
% insulin input effectively sent to the Q(t) subcutaneous absorption block.
% This avoids using controller-internal signals that may still be computed
% even when they are not selected as the applied input.

clear; clc; close all;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'model'));
addpath(fullfile(projectRoot, 'scripts'));

modelName = 'bergman_model';

% Start from a clean in-memory model. This removes temporary probe blocks
% that may have been left by previous runs without saving the .slx file.
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
load_system(fullfile(projectRoot, 'model', [modelName '.slx']));

% Add temporary To Workspace probes for internal model-level signals.
% The model is not saved by this script.
configure_portfolio_output_probes(modelName);

stopTime = '600';
patientProfile = 3;  % type 2 diabetic profile
mealIntensity = 0.2;
glucoseTarget = 100; % mg/dL, used only for summary metrics

scenarios = struct( ...
    'label', {'No external insulin', 'PID control', 'Fuzzy control'}, ...
    'insulinMode', {0, 1, 2});

results = struct([]);

for k = 1:numel(scenarios)
    configure_bergman_model(modelName, patientProfile, scenarios(k).insulinMode, mealIntensity);
    simOut = sim(modelName, 'StopTime', stopTime, 'ReturnWorkspaceOutputs', 'on');

    [tG, G] = extract_sim_signal(simOut, 'G_out');
    [tI, I] = extract_sim_signal(simOut, 'I_out');
    [tX, X] = extract_sim_signal(simOut, 'X_out');
    [tIext, I_ext_applied] = extract_sim_signal(simOut, 'I_ext_applied');
    [tQ, Q_absorbed] = extract_sim_signal(simOut, 'Q_absorbed');

    glucoseDeviation = G - glucoseTarget;

    results(k).label = scenarios(k).label;
    results(k).tG = tG;
    results(k).G = G;
    results(k).tI = tI;
    results(k).I = I;
    results(k).tX = tX;
    results(k).X = X;
    results(k).tIext = tIext;
    results(k).I_ext_applied = I_ext_applied;
    results(k).tQ = tQ;
    results(k).Q_absorbed = Q_absorbed;
    results(k).glucoseDeviation = glucoseDeviation;

    fprintf('\n%s\n', scenarios(k).label);
    fprintf('  Peak glucose: %.2f mg/dL\n', max(G));
    fprintf('  Minimum glucose: %.2f mg/dL\n', min(G));
    fprintf('  Mean absolute glucose deviation from %.0f mg/dL: %.2f mg/dL\n', ...
        glucoseTarget, mean(abs(glucoseDeviation)));
    fprintf('  Peak applied I_ext: %.2f\n', max(I_ext_applied));
    fprintf('  Peak absorbed Q(t): %.2f\n', max(Q_absorbed));
    fprintf('  Peak plasma insulin I(t): %.2f uU/mL\n', max(I));
end

figure('Name', 'Type 2 control strategy comparison', 'NumberTitle', 'off');

subplot(5, 1, 1);
hold on;
for k = 1:numel(results)
    plot(results(k).tG, results(k).G, 'LineWidth', 1.5);
end
ylabel('G(t) [mg/dL]');
title('Blood glucose response');
legend({results.label}, 'Location', 'best');
grid on;

subplot(5, 1, 2);
hold on;
for k = 1:numel(results)
    plot(results(k).tIext, results(k).I_ext_applied, 'LineWidth', 1.5);
end
ylabel('I_{ext}(t)');
title('Applied exogenous insulin input');
legend({results.label}, 'Location', 'best');
grid on;

subplot(5, 1, 3);
hold on;
for k = 1:numel(results)
    plot(results(k).tQ, results(k).Q_absorbed, 'LineWidth', 1.5);
end
ylabel('Q(t)');
title('Absorbed subcutaneous insulin');
legend({results.label}, 'Location', 'best');
grid on;

subplot(5, 1, 4);
hold on;
for k = 1:numel(results)
    plot(results(k).tI, results(k).I, 'LineWidth', 1.5);
end
ylabel('I(t) [\muU/mL]');
title('Plasma insulin response');
legend({results.label}, 'Location', 'best');
grid on;

subplot(5, 1, 5);
hold on;
for k = 1:numel(results)
    plot(results(k).tX, results(k).X, 'LineWidth', 1.5);
end
xlabel('Time [min]');
ylabel('X(t)');
title('Delayed insulin action');
legend({results.label}, 'Location', 'best');
grid on;

sgtitle('Type 2 diabetic profile: control strategy comparison');

figuresDir = fullfile(projectRoot, 'figures');
if ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end
saveas(gcf, fullfile(figuresDir, 'type2_control_strategy_comparison.png'));
