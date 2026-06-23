%% Inspect configurable selector blocks
% This utility checks that the scripts are finding the intended selector
% blocks. It does not add probes and does not run a simulation.

clear; clc;

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

config = configure_bergman_model(modelName, 1, 0, 0.2);

fprintf('\nConfigured selector blocks\n');
fprintf('--------------------------\n');
fprintf('Patient selector: %s | Value = %s\n', config.patientBlock, get_param(config.patientBlock, 'Value'));
fprintf('Insulin selector: %s | Value = %s\n', config.insulinBlock, get_param(config.insulinBlock, 'Value'));
fprintf('Meal intensity:   %s | Value = %s\n', config.mealBlock, get_param(config.mealBlock, 'Value'));

fprintf('\nExpected selector values after this check: patient = 1, insulin/control = 0, meal intensity = 0.2\n');
fprintf('No temporary output probes were added by this inspection script.\n');
