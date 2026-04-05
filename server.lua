local function notify(src, msg, ntype)
    -- ox_lib notify (safe default)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Search',
        description = msg,
        type = ntype or 'inform'
    })
end

local function isTargetDownedWasabi(targetId)
    -- wasabi_ambulance: Player(id).state.dead == 'dead' or 'laststand'
    local state = Player(targetId).state.dead
    return (state == 'dead' or state == 'laststand')
end

RegisterNetEvent('skeezle_rob:searchPlayer', function(targetId)
    local src = source
    targetId = tonumber(targetId)

    if not targetId or targetId <= 0 then return end
    if src == targetId then return end

    local srcPed = GetPlayerPed(src)
    local tgtPed = GetPlayerPed(targetId)
    if not srcPed or srcPed == 0 or not tgtPed or tgtPed == 0 then return end

    -- Distance check (anti-abuse)
    local srcCoords = GetEntityCoords(srcPed)
    local tgtCoords = GetEntityCoords(tgtPed)
    local dist = #(srcCoords - tgtCoords)
    if dist > 2.5 then
        notify(src, 'You are too far away.', 'error')
        return
    end

    -- ✅ Allow if target is downed (wasabi laststand/dead) OR hands up
    local allowed = false

    if isTargetDownedWasabi(targetId) then
        allowed = true
    else
        -- Ask the TARGET client if they are playing a hands-up animation
        allowed = lib.callback.await('skeezle_rob:isTargetHandsUp', targetId, src) == true
    end

    if not allowed then
        notify(src, 'They must have their hands up or be downed.', 'error')
        return
    end

    -- Open target inventory
    exports.ox_inventory:forceOpenInventory(src, 'player', targetId)
end)
