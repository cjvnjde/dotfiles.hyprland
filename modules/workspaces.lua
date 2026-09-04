for workspace = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(workspace),
        persistent = true,
    })
end
