function config = configure_bergman_model(modelName, patientProfile, insulinMode, mealIntensity)
%CONFIGURE_BERGMAN_MODEL Configure the main Simulink model before simulation.
%
% Patient profiles:
%   1 = healthy subject
%   2 = type 1 diabetic profile
%   3 = type 2 diabetic profile
%
% Insulin/control modes, based on the model selector:
%   0 = no external insulin / no controller
%   1 = PID controller
%   2 = fuzzy controller
%
% Meal intensity:
%   scaling factor applied to the meal input inside the G(t) subsystem.
%   The original model default is 0.2.
%
% The function returns the paths of the blocks that were configured. This is
% useful for checking that the intended Simulink blocks were actually found.

    if nargin < 4 || isempty(mealIntensity)
        mealIntensity = 0.2;
    end

    validateattributes(patientProfile, {'numeric'}, {'scalar', 'integer', '>=', 1, '<=', 3});
    validateattributes(insulinMode, {'numeric'}, {'scalar', 'integer', '>=', 0, '<=', 2});
    validateattributes(mealIntensity, {'numeric'}, {'scalar', 'real', 'nonnegative'});

    if ~bdIsLoaded(modelName)
        load_system(modelName);
    end

    patientBlock = set_block_value_by_name(modelName, sprintf('Selettore paziente\n(1-3)'), num2str(patientProfile));
    insulinBlock = set_block_value_by_name(modelName, 'INSULINA ESOGENA', num2str(insulinMode));
    mealBlock    = set_block_value_by_name(modelName, 'Intensità del pasto', num2str(mealIntensity));

    config = struct();
    config.modelName = modelName;
    config.patientProfile = patientProfile;
    config.insulinMode = insulinMode;
    config.mealIntensity = mealIntensity;
    config.patientBlock = patientBlock;
    config.insulinBlock = insulinBlock;
    config.mealBlock = mealBlock;
end

function selectedBlock = set_block_value_by_name(modelName, blockName, value)
%SET_BLOCK_VALUE_BY_NAME Find a block by displayed name and set its Value.
% The search includes all variant choices when the installed Simulink
% version supports the MatchFilter argument. This avoids the R2024b warning
% produced by find_system when the model contains Variant Subsystem blocks.

    blocks = find_blocks_by_name(modelName, blockName);

    if isempty(blocks)
        % Fallback: search by normalized displayed names. This handles small
        % formatting differences such as newlines or carriage returns.
        allBlocks = find_all_blocks(modelName);
        allNames = get_param(allBlocks, 'Name');
        if ischar(allNames)
            allNames = {allNames};
        end

        normalizedTarget = normalize_block_name(blockName);
        normalizedNames = cellfun(@normalize_block_name, allNames, 'UniformOutput', false);
        matches = strcmp(normalizedNames, normalizedTarget);
        blocks = allBlocks(matches);
    end

    if isempty(blocks)
        error('Block not found: %s', blockName);
    end

    if numel(blocks) > 1
        warning('Multiple blocks named "%s" found. Using the first match: %s', blockName, blocks{1});
    end

    selectedBlock = blocks{1};
    set_param(selectedBlock, 'Value', value);

    % Basic post-set verification.
    actualValue = get_param(selectedBlock, 'Value');
    if ~strcmp(strtrim(actualValue), strtrim(value))
        warning('Block "%s" was set to "%s", but current Value is "%s".', selectedBlock, value, actualValue);
    end
end

function blocks = find_blocks_by_name(modelName, blockName)
    try
        blocks = find_system(modelName, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'MatchFilter', @Simulink.match.allVariants, ...
            'Type', 'Block', ...
            'Name', blockName);
    catch
        % Compatibility fallback for older MATLAB/Simulink versions.
        blocks = find_system(modelName, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'Type', 'Block', ...
            'Name', blockName);
    end
end

function blocks = find_all_blocks(modelName)
    try
        blocks = find_system(modelName, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'MatchFilter', @Simulink.match.allVariants, ...
            'Type', 'Block');
    catch
        % Compatibility fallback for older MATLAB/Simulink versions.
        blocks = find_system(modelName, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'Type', 'Block');
    end
end

function out = normalize_block_name(in)
    out = strrep(in, sprintf('\r'), '');
    out = strrep(out, sprintf('\n'), ' ');
    out = regexprep(out, '\s+', ' ');
    out = strtrim(out);
end
