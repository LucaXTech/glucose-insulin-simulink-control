# Glucose–Insulin Simulink Control Portfolio

Academic MATLAB/Simulink portfolio project on glucose–insulin dynamics modelling and control using an extended Bergman-based model.

The project documents a simplified biomedical control-system workflow developed for academic purposes. It is intended as a technical portfolio example in biomedical modelling, simulation and control.

> **Disclaimer:** this is an academic modelling project. It is not a clinical model, not a medical device algorithm and not intended for therapeutic decision-making.

## Project scope

The Simulink model explores glucose–insulin regulation under different simulated patient profiles and control strategies:

- healthy subject profile;
- type 1 diabetic profile;
- type 2 diabetic / insulin-resistant profile;
- external insulin input;
- PID-based control;
- fuzzy-logic-based control;
- meal intake simulation;
- subcutaneous insulin absorption dynamics.

The model is based on a Bergman-style glucose–insulin framework with academic extensions for meal input, exogenous insulin absorption and counter-regulatory behaviour.

## Repository structure

```text
model/
  bergman_model.slx
  fuzzy_diabete.fis

data/
  pasto.mat

scripts/
  inspect_model_selectors.m
  run_healthy_vs_type2_baseline.m
  run_control_strategy_comparison.m
  run_baseline_patient_profiles.m
  run_all_scenarios.m
  configure_bergman_model.m
  configure_portfolio_signal_logging.m
  enable_probed_output_signal.m
  extract_sim_signal.m
  extract_probed_signal.m

figures/
  generated output figures

docs/
  model_configuration.md
  project_summary.md
```

## Main scripts

Run these scripts from the repository root in MATLAB:

```matlab
run('scripts/inspect_model_selectors.m')
run('scripts/run_healthy_vs_type2_baseline.m')
run('scripts/run_control_strategy_comparison.m')
```

`inspect_model_selectors.m` checks that the scripts can find the intended Simulink selector blocks. It does not modify the model.

`run_healthy_vs_type2_baseline.m` compares healthy and type 2 profiles with external insulin/control disabled.

`run_control_strategy_comparison.m` compares, for the type 2 profile, three scenarios:

- no external insulin;
- PID control;
- fuzzy control.

The control-comparison script plots the selected applied exogenous insulin input `I_ext_applied`, the absorbed subcutaneous insulin `Q_absorbed`, plasma insulin `I(t)`, delayed insulin action `X(t)` and blood glucose `G(t)`.

## Important signal-logging note

The original Simulink model contains controller-internal signals and model-level selected signals. For portfolio figures, the script logs:

- `I_ext_applied`: the exogenous insulin input after the model-level selector and after the pathological-profile gate;
- `Q_absorbed`: the output of the subcutaneous insulin absorption subsystem `Q(t)`.

This makes the plotted insulin input correspond to the input actually delivered to the physiological absorption block in each scenario.

## Software

Developed and tested with MATLAB/Simulink in an academic environment. The scripts reload the Simulink model before adding temporary plotting probes, so repeated runs should not require saving the model.

## Author

Luca Serioli  
Biomedical Engineering MSc
