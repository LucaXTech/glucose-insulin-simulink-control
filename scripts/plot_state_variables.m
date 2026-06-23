%% Plot state variables from a completed simulation
% Run the Simulink model first and make sure that the simulation output
% variable is named `simOut` or `out` in the MATLAB workspace.

if exist('simOut', 'var')
    simulationOutput = simOut;
elseif exist('out', 'var')
    simulationOutput = out;
else
    error('Simulation output variable not found. Run the model first and keep the output as simOut or out.');
end

[tG, G] = extract_sim_signal(simulationOutput, 'G_out');
[tX, X] = extract_sim_signal(simulationOutput, 'X_out');
[tI, I] = extract_sim_signal(simulationOutput, 'I_out');

figure('Name', 'State variables', 'NumberTitle', 'off');

subplot(3, 1, 1);
plot(tX, X, 'LineWidth', 1.5);
ylabel('Insulin action X(t)');
title('Delayed insulin action');
grid on;

subplot(3, 1, 2);
plot(tG, G, 'LineWidth', 1.5);
ylabel('Glucose G(t) [mg/dL]');
title('Blood glucose over time');
grid on;

subplot(3, 1, 3);
plot(tI, I, 'LineWidth', 1.5);
ylabel('Insulin I(t) [\muU/mL]');
xlabel('Time [min]');
title('Plasma insulin');
grid on;
