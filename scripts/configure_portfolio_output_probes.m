function probeInfo = configure_portfolio_output_probes(modelName)
%CONFIGURE_PORTFOLIO_OUTPUT_PROBES Add temporary To Workspace probes.
%
% This function adds two temporary To Workspace blocks to the in-memory
% Simulink model. They are not saved unless the user explicitly saves the
% model. The calling scripts intentionally reload the model before adding the
% probes, so repeated runs start from a clean model.
%
% Probed signals:
%   I_ext_applied: output of the pathological-profile gate, i.e. the
%                  exogenous insulin input actually sent to Q(t).
%   Q_absorbed:    output of the Q(t) subcutaneous absorption subsystem.

    if ~bdIsLoaded(modelName)
        load_system(modelName);
    end

    % Remove possible leftovers from an interrupted previous run.
    cleanup_portfolio_probe(modelName, 'I_ext_applied');
    cleanup_portfolio_probe(modelName, 'Q_absorbed');

    probeInfo = struct();

    probeInfo.I_ext_applied_block = add_to_workspace_probe( ...
        modelName, ...
        'Attiva controller solo per casi patologici', ...
        'I_ext_applied', ...
        [4350 1170 4550 1210]);

    probeInfo.Q_absorbed_block = add_to_workspace_probe( ...
        modelName, ...
        'Q(t) Insulina esogena assorbita sottocutaneamente', ...
        'Q_absorbed', ...
        [5000 650 5200 690]);
end

function cleanup_portfolio_probe(modelName, variableName)
%CLEANUP_PORTFOLIO_PROBE Delete an old temporary probe block, if present.

    probeName = ['PortfolioProbe_' variableName];
    existing = find_system(modelName, ...
        'SearchDepth', 1, ...
        'Type', 'Block', ...
        'Name', probeName);

    for i = 1:numel(existing)
        try
            delete_block(existing{i});
        catch ME
            warning('Could not delete existing probe block "%s": %s', existing{i}, ME.message);
        end
    end
end

function probeBlock = add_to_workspace_probe(modelName, sourceBlockDisplayName, variableName, position)
%ADD_TO_WORKSPACE_PROBE Connect a temporary To Workspace block to a block output.
%
% Important: this uses the source outport handle directly. In Simulink this
% creates a branch when the source output already has a downstream line. This
% worked with the original academic model and avoids using line-level
% DataLogging, which is not available for all line types/releases.

    sourceBlock = find_block_by_display_name(modelName, sourceBlockDisplayName);

    probeName = ['PortfolioProbe_' variableName];
    probeBlock = [modelName '/' probeName];

    add_block('simulink/Sinks/To Workspace', probeBlock, ...
        'VariableName', variableName, ...
        'SaveFormat', 'Timeseries', ...
        'MaxDataPoints', 'inf', ...
        'SampleTime', '-1', ...
        'Position', position);

    srcPorts = get_param(sourceBlock, 'PortHandles');
    dstPorts = get_param(probeBlock, 'PortHandles');

    if isempty(srcPorts.Outport) || srcPorts.Outport(1) == -1
        error('No valid output port found for block: %s', sourceBlock);
    end
    if isempty(dstPorts.Inport) || dstPorts.Inport(1) == -1
        error('No valid input port found for probe block: %s', probeBlock);
    end

    try
        add_line(modelName, srcPorts.Outport(1), dstPorts.Inport(1), 'autorouting', 'on');
    catch ME
        error('Could not connect probe "%s" to source block "%s": %s', ...
            probeName, sourceBlock, ME.message);
    end
end
