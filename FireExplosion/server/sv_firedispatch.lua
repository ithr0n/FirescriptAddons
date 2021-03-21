local fireonline = 0
local cooldown = false
local cooldowntimer = false
local timeouttimer = false

-- Admin command --
-- ############# --
--[[
if Config.AdminCommand then
    RegisterCommand('startfire', function(source, args, rawCommand)
        local player = source
        local ped = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(ped)
        TriggerEvent('FireScript:StartFire', source, playerCoords, tonumber(args[1]), tonumber(args[2]))
        if Config.Timeout ~= false then
            StartTimeout()
        end
    end, true)
end
--]]

-- Dynamic triggers on fire script --
-- ############################### --


AddEventHandler('explosionEvent', function(sender, ev, coords)
    if Config.EnableTriggers then
        local allow = true -- false
        if cooldown == false then
           --[[ Check for job stuff --
            if Config.JobCheck then
                if tonumber(fireonline) >= Config.MinJob then
                    allow = true
                end
            else
                allow = true
            end
            --]]
            Wait(math.random(100, 500))
            Citizen.CreateThread(function()
                for _, v in ipairs(Config.Triggers) do
                    if ev.explosionType == v.id then -- if we have the trigger in our table
                        CancelEvent() -- Cancel the event and we will make our own fire
                        if allow then
                            if v.chance then
                                local odds = math.random(1, v.chanceodds)
                                if odds == 1 then
                                    TriggerFireScript(sender, vec3(ev.posX, ev.posY, ev.posZ + 1.0), v.intensity, v.size)  
                                end
                            else
                                if math.abs(ev.posZ) < 1.0 then -- Checks for some events (like car explosions) which do not give world coords
                                    local player = sender
                                    local ped = GetPlayerPed(player)
                                    if v.id == 7 or v.id == 8 or v.id == 10 or v.id == 17 then
                                        Citizen.Wait(7000) -- Delay to let the vehicle come to rest (hacky way I know)
                                        player = sender -- Get this again just in case
                                        ped = GetPlayerPed(player) -- Get this again just in case
                                        local vehicle = GetVehiclePedIsIn(ped, false)
                                        if vehicle == 0 then
                                            vehicle = GetVehiclePedIsIn(ped, true)
                                        end
                                        local playerCoords = GetEntityCoords(vehicle)
                                        local updatedcoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
                                        TriggerFireScript(sender, updatedcoords, v.intensity, v.size)  
                                    else   
                                        local playerCoords = GetEntityCoords(ped)           
                                        TriggerFireScript(sender, playerCoords, v.intensity, v.size)            
                                    end
                                end
                                TriggerFireScript(sender, vec3(ev.posX, ev.posY, ev.posZ + 1.0), v.intensity, v.size)
								TriggerClientEvent('fd:dispatch', sender, ev, coords)								
                            end
                        end
                    end
                end
            end)
        end
    end
end)

function TriggerFireScript(sender, position, inensity, radius)
    if cooldown == false then -- Double check here in case multiple fires start at once
        cooldown = true
        TriggerEvent('FireScript:StartFire', sender, position, inensity, radius)
        if Config.Timeout ~= false then
            StartTimeout()
        end
    end
end

CreateThread(function()
    while Config.JobCheck do
        Wait(Config.Cooldown)
        fireonline = 0
        local xPlayers = ExM.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ExM.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == Config.Job then
                fireonline = fireonline + 1
            end
        end
    end
end)
      
RegisterServerEvent('FireDispatch:Disable')
AddEventHandler('FireDispatch:Disable', function()
    StartCooldown()
    if timeouttimer == true then
        timeouttimer = false -- Disable timeout timer
    end
end)

function StartCooldown() -- Cooldown between fires
    CreateThread(function()
        if cooldowntimer == false then -- This is another double check to not set multiple timers
            cooldowntimer = true
            print('COOLDOWN SAT I GANG')
            SetTimeout((Config.Cooldown * 60000), function()
                print('COOLDOWN SLUTTET BRÆNDER ER AKTIVERET')
                cooldown = false
                cooldowntimer = false
            end)
        end
    end)
end

function StartTimeout() -- Fire timeout (safety in case somehow the fire can not be put out)
    CreateThread(function()
        if timeouttimer == false then -- This is another double check to not set multiple timers
            timeouttimer = true
            SetTimeout((Config.Timeout * 60000), function()
                if timeouttimer == true then
                    TriggerClientEvent('FireScript:FireTimeout', -1)
                    print('BRAND ER SLUKKE')
                    timeouttimer = false
                end
            end)
        end
    end)
end
