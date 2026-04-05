-- Works with ox_target + optional /steal command.

local lastAttempt = 0

local function Notify(msg, ntype)
    -- ox_lib notify if available, fallback to print
    if lib and lib.notify then
        lib.notify({
            title = 'Robbery',
            description = msg,
            type = ntype or 'inform'
        })
    else
        print(('[Robbery] %s'):format(msg))
    end
end

local function IsPedHandsUp(ped)
    if not ped or ped == 0 then return false end
    -- GTA native (very reliable)
    if IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3) then return true end
    if IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3) then return true end
    if IsEntityPlayingAnim(ped, 'anim@mp_player_intuppersurrender', 'idle_a', 3) then return true end
    if IsEntityPlayingAnim(ped, 'anim@mp_player_intuppersurrender', 'enter', 3) then return true end
    if IsEntityPlayingAnim(ped, 'anim@mp_player_intuppersurrender', 'exit', 3) then return true end

    -- Config-defined fallback list
    for _, a in ipairs(Config.HandsUpAnims or {}) do
        if IsEntityPlayingAnim(ped, a.dict, a.name, 3) then
            return true
        end
    end
    return false
end

local function IsLocalPlayerKnockedOut()
    local state = LocalPlayer and LocalPlayer.state
    if not state then return false end

    for _, key in ipairs(Config.DownedStateKeys or {}) do
        if state[key] then
            return true
        end
    end
    return false
end

local function CanAttemptRobbery()
    if Config.BlockRobbingWhileKnockedOut and IsLocalPlayerKnockedOut() then
        Notify("You can't rob while knocked out.", 'error')
        return false
    end

    local now = GetGameTimer()
    local cdMs = (Config.CooldownSeconds or 0) * 1000
    if cdMs > 0 and (now - lastAttempt) < cdMs then
        local remain = math.ceil((cdMs - (now - lastAttempt)) / 1000)
        Notify(("Slow down. Wait %ss."):format(remain), 'error')
        return false
    end

    if Config.RequireUnarmed then
        local ped = PlayerPedId()
        if IsPedArmed(ped, 7) then
            Notify("You must be unarmed to rob.", 'error')
            return false
        end
    end

    return true
end

local function PlayRobAnim()
    local ped = PlayerPedId()
    local dict = (Config.RobAnim and Config.RobAnim.dict) or 'mp_arresting'
    local name = (Config.RobAnim and Config.RobAnim.name) or 'a_uncuff'

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskPlayAnim(ped, dict, name, 8.0, -8.0, (Config.RobberyDuration or 3500), 49, 0.0, false, false, false)
end

local function DoProgress(label, duration)
    duration = duration or 3500

    -- ox_lib progress
    if lib and lib.progressCircle then
        return lib.progressCircle({
            duration = duration,
            position = 'bottom',
            label = label or 'Robbing...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
        })
    end

    -- fallback (no cancel)
    Notify(label or 'Robbing...', 'inform')
    Wait(duration)
    return true
end

local function GetClosestPlayerWithin(maxDist)
    local ped = PlayerPedId()
    local myCoords = GetEntityCoords(ped)
    local closestPlayer, closestDist = nil, maxDist + 0.001

    for _, ply in ipairs(GetActivePlayers()) do
        local tgtPed = GetPlayerPed(ply)
        if tgtPed ~= ped then
            local dist = #(GetEntityCoords(tgtPed) - myCoords)
            if dist < closestDist then
                closestDist = dist
                closestPlayer = ply
            end
        end
    end

    if closestPlayer then
        return closestPlayer, closestDist
    end
    return nil, nil
end

local function AttemptRobPlayer(targetServerId)
    if not CanAttemptRobbery() then return end
    lastAttempt = GetGameTimer()

    -- Start anim + progress
    PlayRobAnim()
    local ok = DoProgress('Robbing...', Config.RobberyDuration or 3500)
    ClearPedTasks(PlayerPedId())

    if not ok then
        Notify('Cancelled.', 'error')
        return
    end

    -- Server side should validate target state + distance + etc.
    TriggerServerEvent('wasabi_steal:server:attemptRob', targetServerId)
end

--========================================================
-- /steal command (optional)
--========================================================
if Config.EnableCommand then
    RegisterCommand(Config.Command or 'steal', function()
        local maxDist = Config.MaxDistance or 2.0
        local closestPlayer = GetClosestPlayerWithin(maxDist)

        if not closestPlayer then
            Notify('No one nearby.', 'error')
            return
        end

        local targetServerId = GetPlayerServerId(closestPlayer)
        AttemptRobPlayer(targetServerId)
    end, false)
end

--========================================================
-- ox_target option
--========================================================
CreateThread(function()
    if not (Config.Target and Config.Target.Enabled) then return end
    if not exports.ox_target then
        Notify('ox_target not found (Target.Enabled=true).', 'error')
        return
    end

    exports.ox_target:addGlobalPlayer({
        {
            name = 'wasabi_steal:rob',
            icon = Config.Target.Icon or 'fa-solid fa-mask',
            label = Config.Target.Label or 'Rob',
            distance = Config.MaxDistance or 2.0,

            canInteract = function(entity, distance, coords, name)
                if Config.Target.DebugAlwaysShow then
                    return true
                end

                -- block if robber is KO
                if Config.BlockRobbingWhileKnockedOut and IsLocalPlayerKnockedOut() then
                    return false
                end

                if distance and (distance > (Config.MaxDistance or 2.0)) then
                    return false
                end

                -- Only show if target has hands up (you can change this logic to include laststand, etc.)
                return IsPedHandsUp(entity)
            end,

            onSelect = function(data)
                if not data or not data.entity then return end
                local ply = NetworkGetPlayerIndexFromPed(data.entity)
                if not ply or ply == -1 then return end

                local targetServerId = GetPlayerServerId(ply)
                AttemptRobPlayer(targetServerId)
            end
        }
    })
end)