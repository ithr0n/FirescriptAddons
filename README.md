![Logo](https://i.imgur.com/lKBSPoC.png)

[![License GNU-GPL v3](https://img.shields.io/github/license/gimicze/firescript?style=for-the-badge)](https://github.com/Wick89/FirescriptAddons/blob/main/LICENSE "License")
[![Latest release](https://img.shields.io/github/v/release/gimicze/firescript?style=for-the-badge)](https://github.com/Wick89/FirescriptAddons/releases "Latest release")
[![Total downloads](https://img.shields.io/github/downloads/gimicze/firescript/total?style=for-the-badge)](https://github.com/Wick89/FirescriptAddons/releases "Total downloads")

[wiki](https://github.com/Wick89/FirescriptAddons/wiki)

# FirescriptAddons
[Firescript addons] all in one addons

- make a map [Firescript addons]

- add it in map
```
Firescript
HoseLS
saw
inferno-fire-ems-pager
inferno-pass-alarm
inferno-ladders
```
 
- start Firescript

- start HoseLS

- start saw

- start inferno-fire-ems-pager

- start inferno-pass-alarm

- start inferno-ladders 


add exec "resources/[Firescript addons]\inferno-fire-ems-pager/inferno-fire-ems-pager.cfg" to server.cfg

# Credits


- Albo1125 and foregz - gimicze

# thanks to https://github.com/inferno-collection for make Addons

# LondonStudios for make HoseLS

# If using ESX / QBCore

1, go to config.lua line 18 and 32


# use qb-target / eyes

1, add it

```
RegisterNetEvent('Toggle:LSFDDuty')
AddEventHandler('Toggle:LSFDDuty', function()
    onDuty = not onDuty
    TriggerServerEvent("QBCore:ToggleDuty")
    TriggerServerEvent("fire:server:firedispatch", source) -- for firecall 
end)
```

# for vrp

1. Add this line to Client.lua make your own
```
RegisterNetEvent("ondutyfire")
AddEventHandler("ondutyfire", function()
  TriggerServerEvent('fireDispatch:registerPlayer', -1, subscribe)
end)
```

```
RegisterNetEvent("offdutyfire")
AddEventHandler("offdutyfire", function()
  TriggerServerEvent('fireDispatch:removePlayer', -1, unsubscribe)
end)
```

---------------Text3D-----------------------
```
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
  end
```
```
Citizen.CreateThread(function()
    Citizen.Wait(1)
    while true do
      Citizen.Wait(1) 
	  -- fire
		elseif GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 198.77629089355,-1651.1002197266,29.803224563599) < 3 then
			  DrawMarker(20, 198.77629089355,-1651.1002197266,29.803224563599-0.2, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5001, 83, 255, 87, 200, 1, 1, 0, 1)
        DrawText3Ds(198.77629089355,-1651.1002197266,29.803224563599+0.1, "~r~[F]~s~ To go offduty/onduty.")
        if IsControlJustPressed(1, 145) then
          TriggerServerEvent("wk:job")
        end
      end
    end
end)
```

2. Add this line to server.lua
```
RegisterServerEvent('wk:job')
AddEventHandler('wk:job', function()
    local source = source
	local user_id = vRP.getUserId({source})
  -- POLITI
	if vRP.hasGroup({user_id,"ems"}) then
		if vRP.hasGroup({user_id,"Fireman"}) then
			TriggerClientEvent('offdutyfire', source)
			vRP.removeUserGroup({user_id, "Fireman"})
		else
			TriggerClientEvent('ondutyfire', source)
			vRP.addUserGroup({user_id, "Fireman"})
		end
	end
end)
```

# VRP2 

1. Client.lua have make my own Functions resources
```
function Functions:onDuty()
  TriggerServerEvent('fireDispatch:registerPlayer', -1, subscribe)
end
```
```
function Functions:offDuty()
  TriggerServerEvent('fireDispatch:removePlayer', -1, unsubscribe)
end
```

2. \vrp\cfg\groups

```
function ems_init(user)
  vRP.EXT.Functions.remote._onDuty(user.source)
end
```
```
function ems_onjoin(user)
  ems_init(user)
end
```
```
function ems_onleave(user)
  vRP.EXT.Functions.remote._offDuty(user.source)
  user:removeCloak()
end
```
```
function ems_onspawn(user)
  ems_init(user)
end
```

