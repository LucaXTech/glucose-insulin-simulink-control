function [t, y, rawSignal] = extract_sim_signal(simOut, signalName)
%EXTRACT_SIM_SIGNAL Extract time and values from a Simulink output signal.
% Supports both timeseries and Structure With Time outputs.

    rawSignal = [];

    if isa(simOut, 'Simulink.SimulationOutput')
        try
            rawSignal = simOut.get(signalName);
        catch
            error('Signal "%s" not found in SimulationOutput.', signalName);
        end
    elseif isstruct(simOut) && isfield(simOut, signalName)
        rawSignal = simOut.(signalName);
    else
        error('Unsupported simulation output type for signal extraction.');
    end

    if isa(rawSignal, 'timeseries')
        t = rawSignal.Time;
        y = squeeze(rawSignal.Data);
    elseif isstruct(rawSignal) && isfield(rawSignal, 'time') && isfield(rawSignal, 'signals')
        t = rawSignal.time;
        y = squeeze(rawSignal.signals.values);
    else
        error('Unsupported format for signal "%s".', signalName);
    end
end
