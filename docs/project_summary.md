# Project summary

This portfolio project presents a simplified MATLAB/Simulink model of glucose–insulin dynamics with configurable patient profiles and insulin-control strategies.

## Goals

- Simulate glucose response after meal intake.
- Compare different physiological patient profiles.
- Explore the effect of external insulin input.
- Compare PID and fuzzy-logic control strategies in a type 2 diabetic profile.
- Document a biomedical modelling and simulation workflow suitable for academic portfolio use.

## Model components

The model includes:

- a Bergman-style glucose–insulin core;
- meal intake as an external glucose stimulus;
- subcutaneous exogenous insulin absorption;
- patient-dependent parameters;
- PID and fuzzy control options;
- glucose, plasma insulin and delayed insulin-action outputs.

## Main demonstration scenarios

### Healthy vs Type 2 baseline

The script `run_healthy_vs_type2_baseline.m` compares healthy and type 2 profiles with external insulin/control disabled. This provides a readable baseline comparison of intrinsic model dynamics.

### Type 2 control-strategy comparison

The script `run_control_strategy_comparison.m` compares, under the same meal input:

- no external insulin;
- PID control;
- fuzzy control.

It plots blood glucose, applied exogenous insulin input, absorbed subcutaneous insulin, plasma insulin and delayed insulin action.

## Limitations

This is a simplified academic model. It is not validated for clinical use and should not be interpreted as a therapeutic simulation tool. Parameter values and controller settings are used for educational exploration of model-based biomedical control concepts.
