%% Run the main demonstration scripts
% These scripts generate the figures used to document the portfolio project.

run('scripts/inspect_model_selectors.m');
run('scripts/run_healthy_vs_type2_baseline.m');
run('scripts/run_control_strategy_comparison.m');

% Optional: includes the uncontrolled type 1 profile, which is expected to
% produce very high glucose in this simplified academic model.
% run('scripts/run_baseline_patient_profiles.m');
