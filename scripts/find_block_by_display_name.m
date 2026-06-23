function blockPath = find_block_by_display_name(modelName, displayedName)
%FIND_BLOCK_BY_DISPLAY_NAME Find one Simulink block by displayed block name.
% The comparison is robust to newlines and repeated spaces in block labels.

    if ~bdIsLoaded(modelName)
        load_system(modelName);
    end

    allBlocks = find_all_blocks(modelName);
    allNames = get_param(allBlocks, 'Name');
    if ischar(allNames)
        allNames = {allNames};
    end

    normalizedTarget = normalize_block_name(displayedName);
    normalizedNames = cellfun(@normalize_block_name, allNames, 'UniformOutput', false);
    matches = strcmp(normalizedNames, normalizedTarget);
    blockMatches = allBlocks(matches);

    if isempty(blockMatches)
        error('Block not found: %s', displayedName);
    end

    if numel(blockMatches) > 1
        warning('Multiple blocks matching "%s" found. Using the first match: %s', displayedName, blockMatches{1});
    end

    blockPath = blockMatches{1};
end

function blocks = find_all_blocks(modelName)
    try
        blocks = find_system(modelName, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'MatchFilter', @Simulink.match.allVariants, ...
            'Type', 'Block');
    catch
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
