Config = {}

--========================================================
-- Basics
--========================================================

-- Enable /steal command in addition to ox_target
Config.EnableCommand = true
Config.Command = 'steal'

-- Max distance to rob / see ox_target option
Config.MaxDistance = 2.0

-- Cooldown between attempts (seconds)
Config.CooldownSeconds = 8

-- Require robber to be unarmed
Config.RequireUnarmed = false

--========================================================
-- Robbery animation / progress
--========================================================

-- How long the "robbing..." progress lasts (ms)
Config.RobberyDuration = 3500

-- Animation played on the ROBBER while robbing
Config.RobAnim = { dict = 'mp_arresting', name = 'a_uncuff' }

--========================================================
-- Hands-up detection
--========================================================
-- Note: client.lua also uses IsPedHandsUp() which is very reliable.
Config.HandsUpAnims = {
  { dict = 'missminuteman_1ig_2', name = 'handsup_base' },
  { dict = 'random@mugging3', name = 'handsup_standing_base' },
  { dict = 'anim@mp_player_intuppersurrender', name = 'idle_a' },
  { dict = 'anim@mp_player_intuppersurrender', name = 'enter' },
  { dict = 'anim@mp_player_intuppersurrender', name = 'exit' },
}


--========================================================
-- Downed / last stand / KO (wasabi_ambulance + QBX)
--========================================================

-- If true: you CANNOT rob while you (the robber) are knocked out / downed.
Config.BlockRobbingWhileKnockedOut = false

-- If your server uses different statebag keys, add them here.
Config.DownedStateKeys = {
    'inLaststand', 'laststand', 'isLaststand', 'isInLaststand',
    'knockedOut', 'isKnockedOut',
    'unconscious', 'isUnconscious',
    'incapacitated',
}


--========================================================
-- ox_target option
--========================================================
Config.Target = {
    Enabled = true,
    Label = 'Rob',
    Icon = 'fa-solid fa-mask',

    -- Set true temporarily to confirm the option is registering.
    -- (It will show on all players regardless of state.)
    DebugAlwaysShow = false,
}
