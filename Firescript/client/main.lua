--================================--
--       FIRE SCRIPT v1.6.10      --
--  by GIMI (+ foregz, Albo1125)  --
--      License: GNU GPL 3.0      --
--================================--

local syncInProgress = false

Stations = {"els", "sls", "rh"}
--================================--
--              CHAT              --
--================================--

TriggerEvent("chat:addTemplate", "firescript", '<div style="text-indent: 0 !important; padding: 0.5vw; margin: 0.05vw; color: rgba(255,255,255,0.9);background-color: rgba(250,26,56, 0.8); border-radius: 4px;"><b>{0}</b> {1} </div>')

TriggerEvent('chat:addSuggestion', '/startfire', 'Opretter en brand', {
	{
		name = "spredning",
		help = "Hvor mange gange kan ilden spredes?"
	},
	{
		name = "chance",
		help = "0 - 100; Hvor hurtigt branden spredes?"
	},
	{
		name = "dispatch",
		help = "true eller false (Standard false)"
	}
})

TriggerEvent('chat:addSuggestion', '/stopfire', 'Stop ilden', {
	{
		name = "index",
		help = "Ilden's index (ID)"
	}
})

TriggerEvent('chat:addSuggestion', '/stopallfires', 'Stop alle brande')

TriggerEvent('chat:addSuggestion', '/registerfire', 'Registrerer en ny brandkonfiguration')

TriggerEvent('chat:addSuggestion', '/addflame', 'Tilføjer en flamme til en registreret brand', {
	{
		name = "brandID",
		help = "Den registrerede brand"
	},
	{
		name = "spredning",
		help = "Hvor mange gange kan flammen spredes?"
	},
	{
		name = "chance",
		help = "Hvor mange ud af 100 chancer skal ilden sprede sig? (0-100)"
	}
})

TriggerEvent('chat:addSuggestion', '/removeflame', 'Fjerner en flamme fra en registreret brand', {
	{
		name = "brandID",
		help = "brand ID"
	},
	{
		name = "flammeID",
		help = "Flammen ID"
	}
})

TriggerEvent('chat:addSuggestion', '/removefire', 'Fjerner en registreret brand', {
	{
		name = "brandID",
		help = "brand ID"
	}
})

TriggerEvent('chat:addSuggestion', '/startregisteredfire', 'Starter en registreret brand', {
	{
		name = "brandID",
		help = "brand ID"
	},
	{
		name = "triggerDispatch",
		help = "true / false - skal scriptudløseren sendes efter spawning af ​​ilden? (Standard false)"
	}
})

TriggerEvent('chat:addSuggestion', '/stopregisteredfire', 'Stop en registreret brand', {
	{
		name = "brandID",
		help = "brand ID"
	}
})

TriggerEvent('chat:addSuggestion', '/firewl', 'Administrerer whitelist til brandscript', {
	{
		name = "handling",
		help = "add / remove"
	},
	{
		name = "BorgerID",
		help = "Borger i server ID"
	}
})

TriggerEvent('chat:addSuggestion', '/firewlreload', 'Genindlæser whitelist fra konfigurationen')

TriggerEvent('chat:addSuggestion', '/firedispatch', 'Administrerer dispatch på brand script', {
	{
		name = "handling",
		help = "add / remove"
	},
	{
		name = "BorgerID",
		help = "Borger i server ID"
	}
})

TriggerEvent('chat:addSuggestion', '/remindme', 'Indstiller GPS-waypoint til det angivne dispatch.', {
	{
		name = "dispatchID",
		help = "brand id på map (nummer)"
	}
})

TriggerEvent('chat:addSuggestion', '/cleardispatch', 'Rydder navigationen til det sidste dispatch.', {
	{
		name = "dispatchID",
		help = "(valgfri) fjernes blip, hvis det er udfyldt."
	}
})

TriggerEvent('chat:addSuggestion', '/randomfires', 'Administrerer den tilfældige spawner', {
	{
		name = "handling",
		help = "add / remove / enable / disable"
	},
	{
		name = "p2",
		help = "(valgfri) For tilføj / fjern handling, udfyld det registrerede brand-ID."
	}
})

--================================--
--        SYNC ON CONNECT         --
--================================--

RegisterNetEvent('playerSpawned')
AddEventHandler(
	'playerSpawned',
	function()
		print("Requested synchronization..")
		TriggerServerEvent('fireManager:requestSync')
	end
)

RegisterNetEvent('onClientResourceStart')
AddEventHandler(
	'onClientResourceStart',
	function(resourceName)
		if resourceName == GetCurrentResourceName() then
			-- Check the command whitelist
			TriggerServerEvent('fireManager:checkWhitelist')
		end
	end
)

--================================--
--            COMMANDS            --
--================================--

RegisterCommand(
	'remindme',
	function(source, args, rawCommand)
		local dispatchNumber = tonumber(args[1])
		if not dispatchNumber then
			sendMessage("Ugyldigt argument.")
			return
		end

		local success = Dispatch:remind(dispatchNumber)

		if not success then
			sendMessage("Kunne ikke finde den angivne Dispatch.")
			return
		end
	end,
	false
)

RegisterCommand(
	'cleardispatch',
	function(source, args, rawCommand)
		Dispatch:clear(tonumber(args[1]))
	end,
	false
)

RegisterCommand(
	'startfire',
	function(source, args, rawCommand)
		local maxSpread = tonumber(args[1])
		local probability = tonumber(args[2])
		local triggerDispatch = args[3] == "true"

		TriggerServerEvent('fireManager:command:startfire', GetEntityCoords(GetPlayerPed(-1)), maxSpread, probability, triggerDispatch)
	end,
	false
)

RegisterCommand(
	'registerfire',
	function(source, args, rawCommand)
		TriggerServerEvent('fireManager:command:registerfire', GetEntityCoords(GetPlayerPed(-1)))
	end,
	false
)

RegisterCommand(
	'addflame',
	function(source, args, rawCommand)
		local registeredFireID = tonumber(args[1])
		local spread = tonumber(args[2])
		local chance = tonumber(args[3])

		if registeredFireID and spread and chance then
			TriggerServerEvent('fireManager:command:addflame', registeredFireID, GetEntityCoords(GetPlayerPed(-1)), spread, chance)
		end
	end,
	false
)

--================================--
--             EVENTS             --
--================================--

RegisterNetEvent('fireClient:synchronizeFlames')
AddEventHandler(
	'fireClient:synchronizeFlames',
	function(fires)
		syncInProgress = true
		Fire:removeAll(
			function()
				for k, v in pairs(fires) do
					for _k, _v in ipairs(v) do
						Fire:createFlame(k, _k, _v)
					end
				end
				syncInProgress = false
			end
		)
	end
)

RegisterNetEvent('fireClient:removeFire')
AddEventHandler(
	'fireClient:removeFire',
	function(fireIndex)
		while syncInProgress do
			Citizen.Wait(10)
		end
		Fire:remove(fireIndex)
	end
)

RegisterNetEvent('fireClient:removeAllFires')
AddEventHandler(
	'fireClient:removeAllFires',
	function()
		while syncInProgress do
			Citizen.Wait(10)
		end
		Fire:removeAll()
	end
)

RegisterNetEvent("fireClient:removeFlame")
AddEventHandler(
    "fireClient:removeFlame",
	function(fireIndex, flameIndex)
		while syncInProgress do
			Citizen.Wait(10)
		end
		Fire:removeFlame(fireIndex, flameIndex)
    end
)

RegisterNetEvent("fireClient:createFlame")
AddEventHandler(
    "fireClient:createFlame",
	function(fireIndex, flameIndex, coords)
		syncInProgress = true
		Fire:createFlame(fireIndex, flameIndex, coords)
		syncInProgress = false
    end
)

-- Dispatch

if Config.Dispatch.enabled == true then
	RegisterNetEvent('fd:dispatch')
	AddEventHandler(
		'fd:dispatch',
		function(coords)
			local streetName, crossingRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
			local streetName = GetStreetNameFromHashKey(streetName)
			local text = ("En brand brød ud ved %s."):format((crossingRoad > 0) and streetName .. " / " .. GetStreetNameFromHashKey(crossingRoad) or streetName)
			TriggerServerEvent('fireDispatch:create', text, coords)
			
			exports["inferno-fire-ems-pager"]:SoundFireSiren(Stations)
		end
	)
end

RegisterNetEvent('fireClient:createDispatch')
AddEventHandler(
	'fireClient:createDispatch',
	function(dispatchNumber, coords)
		Dispatch:create(dispatchNumber, coords)
	end
)