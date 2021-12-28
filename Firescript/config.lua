--================================--
--      FIRE SCRIPT v1.7.6        --
--  by GIMI (+ foregz, Albo1125)  --
--  make some function by Wick	  --
--      License: GNU GPL 3.0      --
--================================--
Config = {}

Config.Fire = {
    fireSpreadChance = 7, -- Out of 100 chances, how many lead to fire spreading? (not exactly percents)
    maximumSpreads = 8,
    spawner = { -- Requires the use of the built-in dispatch system
        enableOnStartup = true,
        interval = 900000, -- Random fire spawn interval (set to nil or false if you don't want to spawn random fires) in ms
        chance = 50, -- Fire spawn chance (out of 100 chances, how many lead to spawning a fire?); Set to values between 1-100
        players = 1, -- Sets the minimum number of players subscribed to dispatch for the spawner to spawn fires.
        firefighterJobs = { -- If using ESX / QBCore (Config.Dispatch.Framework), you can specify which players will count as firefighters in Config.Fire.spawner.players above; If not using ESX or QB you can set this to nil
            ["firefighter"] = true -- Always set the job name in the key, value has to be true
        }
    }
}

Config.Dispatch = {
    enabled = true, -- Set this to false if you don't want to use the default dispatch system
    timeout = 15000, -- The amount of time in ms to delay the dispatch after the fire has been created
    storeLast = 5, -- The client will store the last five dispatch coordinates for use with /remindme <dispatchNumber>
    clearGpsRadius = 20.0, -- If you don't want to automatically clear the route upon arrival, leave this to false
    removeBlipTimeout = 400000, -- The amount of time in ms after which the dispatch call blip will be automatically removed
    playSound = true,
    playSoundv2 = "chat", -- test for new Sound (come soon) -- inferno or chat or none
    Framework = "add you Framework here", -- * "qb" (qb-core) * "esx" (ESX) for use dispatch
    enableJob = "add you job here" -- Set to a job / jobs you want to be automatically subscribed to dispatch; Set to nil or false if you don't want to use this
}