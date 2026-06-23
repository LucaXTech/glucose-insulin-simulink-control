# Model configuration and logging notes

## Patient selector

The model uses the selector block:

```text
Selettore paziente (1-3)
```

with the following intended values:

```text
1 = healthy subject
2 = type 1 diabetic profile
3 = type 2 diabetic / insulin-resistant profile
```

## Insulin/control selector

The model uses the block:

```text
INSULINA ESOGENA
```

with the following intended values:

```text
0 = no external insulin / no controller
1 = PID control
2 = fuzzy control
```

The script `configure_bergman_model.m` sets these selector values programmatically before each simulation.

## Applied external insulin signal

The model includes controller-specific outputs and model-level selected signals. For the public portfolio figures, the relevant signal is not a controller-internal output, but the input effectively sent to the subcutaneous absorption subsystem.

For this reason, `run_control_strategy_comparison.m` logs:

```text
I_ext_applied
```

from the output of:

```text
Attiva controller solo per casi patologici
```

This signal is downstream of the model-level Multiport Switch and of the pathological-profile gate. It therefore represents the selected exogenous insulin input applied to the patient model in the current scenario.

## Subcutaneous insulin absorption signal

The script also logs:

```text
Q_absorbed
```

from the output of:

```text
Q(t) - Insulina esogena assorbita sottocutaneamente
```

This allows the control comparison to show the chain:

```text
control strategy -> applied I_ext(t) -> absorbed Q(t) -> plasma I(t) -> glucose G(t)
```

## Reproducibility note

The Simulink model is the main object of the portfolio. The scripts provide reproducible demonstration scenarios by setting the main selector blocks and logging the relevant internal signals programmatically. Some interactive switches and scopes are kept in the model to preserve the original academic exploration workflow.
