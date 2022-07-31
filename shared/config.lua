Config = {}
Config.Permission = "god" --set "user" if you dont want perm restriction
Config.Command = "vehdebug" -- in case you want to change name of command

--Configure default speed units and steps for logic & UI
Config.Speed = "KMH" --MPH or KMH
Config.SpeedSteps = {
    [1] = 30,   -- 30 mph
    [2] = 60,   -- 60 mph
    [3] = 90,   -- 90 mph
    [4] = 120,  -- 120 mph
}

--Just in case you flip over
Config.UseFlip = true
Config.Flip = 172   -- "Up arrow" key

--Reset the numbers
Config.Reset = 61 --Currently "Left-Shift"
Config.ResetLabel = "L-Shift" --Only for visuals.

--Configure teleport key.
Config.TeleportToCoords = vector3(-1730.1, -2899.99, 13.67) --Teleport location
Config.TeleportToCoordsHeading = 329.77 --Which way you are looking after being teleported
Config.TeleportToCoordsKey = 306 --Currently "N"
Config.TeleportToCoordsLabel = "N" -- Only for visuals.
