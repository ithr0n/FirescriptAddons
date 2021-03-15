--================================--
--       FIRE SCRIPT v1.7.2       --
--  by GIMI (+ foregz, Albo1125)  --
--  make some function ny Wick	  --
--      License: GNU GPL 3.0      --
--================================--
local fireonline = 0
local cooldown = false
local cooldowntimer = false
local timeouttimer = false

Dispatch = {
	_players = {},
	_firefighters = {},
	lastNumber = 0,
	expectingInfo = {},
	__index = self,
	init = function(object)
		object = object or {_players = {}, _firefighters = {}, lastNumber = 0, expectingInfo = {}}
		setmetatable(object, self)
		return object
	end
}

function Dispatch:create(text, coords)
	text = tostring(text)

	if not (text and coords) then
		return
	end

	self.lastNumber = self.lastNumber + 1

	for k, v in pairs(self._players) do
		sendMessage(k, text, ("Dispatch (#%s)"):format(self.lastNumber))
		TriggerClientEvent('fireClient:createDispatch', k, self.lastNumber, coords)
	end
end

function Dispatch:subscribe(serverId, isFirefighter)
	serverId = tonumber(serverId)
	self._players[serverId] = true
	if not isFirefighter then
		self:addFirefighter(serverId)
	end
end

function Dispatch:unsubscribe(serverId)
	serverId = tonumber(serverId)
	self._players[serverId] = nil
	self:removeFirefighter(serverId)
end

function Dispatch:addFirefighter(serverId)
	serverId = tonumber(serverId)
	self._firefighters[serverId] = true
end

function Dispatch:removeFirefighter(serverId)
	serverId = tonumber(serverId)
	self._firefighters[serverId] = nil
end

function Dispatch:firefighters()
	return table.length(self._firefighters)
end

function Dispatch:players()
	return table.length(self._players)
end

function Dispatch:getRandomPlayer()
	if not next(self._players) then
		return false
	end
	return table.random(self._players)
end

-- Dynamic triggers on fire script --
-- ############################### --


AddEventHandler('explosionEvent', function(sender, ev)
    if Config.EnableTriggers then
        local allow = false
        if cooldown == false then
            --- Check for job stuff ---
            if Config.Dispatch.enabled then
                if tonumber(fireonline) >= Config.Fire.spawner.players then
                    allow = true
                end
            else
                allow = true
            end
            --------------------------
            Wait(math.random(100, 500))
            Citizen.CreateThread(function()
                for _, v in ipairs(Config.Triggers) do
                    if ev.explosionType == v.id then -- if we have the trigger in our table
                        CancelEvent() -- Cancel the event and we will make our own fire
                        if allow then
                            if v.chance then
                                local odds = math.random(1, v.chanceodds)
                                if odds == 1 then
                                    TriggerFireScript(coords, vec3(ev.posX, ev.posY, ev.posZ + 1.0), v.intensity, v.size)							
                                end
                            else
                                if math.abs(ev.posZ) < 1.0 then -- Checks for some events (like car explosions) which do not give world coords
                                    local player = coords
                                    local ped = GetPlayerPed(player)
                                    if v.id == 7 or v.id == 8 or v.id == 10 or v.id == 17 then
                                        Citizen.Wait(7000) -- Delay to let the vehicle come to rest (hacky way I know)
                                        player = coords -- Get this again just in case
                                        ped = GetPlayerPed(player) -- Get this again just in case
                                        local vehicle = GetVehiclePedIsIn(ped, false)
                                        if vehicle == 0 then
                                            vehicle = GetVehiclePedIsIn(ped, true)
                                        end
                                        local playerCoords = GetEntityCoords(vehicle)
                                        local updatedcoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
                                        TriggerFireScript(coords, updatedcoords, v.intensity, v.size)
                                    else   
                                        local playerCoords = GetEntityCoords(ped)           
                                        TriggerFireScript(coords, playerCoords, v.intensity, v.size)
                                    end
                                end
								TriggerFireScript(coords, vec3(ev.posX, ev.posY, ev.posZ + 1.0), v.intensity, v.size)           
                            end
                        end
                    end
                end
            end)
        end
    end
end)

function TriggerFireScript(coords, fireIndex, flameIndex)
    if cooldown == false then -- Double check here in case multiple fires start at once
        cooldown = true
		 TriggerEvent('fireServer:StartFire', sender, position, inensity, radius)
        if Config.Dispatch.timeout ~= false then
            StartTimeout()
        end
    end
end

function StartCooldown() -- Cooldown between fires
    CreateThread(function()
        if cooldowntimer == false then -- This is another double check to not set multiple timers
            cooldowntimer = true
            print('[^1Brand^7] BRÆNDSKRIFT COOLDOWN INITIATED')
            SetTimeout((Config.Dispatch.timeout * 60000), function()
                print('[^1Brand^7] BRANDSKRIFT COOLDOWN SLUTTET | BRÆNDER ER AKTIVERET')
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
            SetTimeout((Config.Dispatch.timeout * 60000), function()
                if timeouttimer == true then
                    TriggerClientEvent('fireClient:FireTimeout', -1)
                    print('[^1Brand^7] BRAND HAR TIMED OUT')
                    timeouttimer = false
                end
            end)
        end
    end)
end
