![Logo](https://i.imgur.com/lKBSPoC.png)


# FirescriptAddons
[Firescript addons] all in one addons

https://www.youtube.com/watch?v=9GNn7LMddy8 (a year ago)

https://www.youtube.com/watch?v=ugzoOLsgEt0 (Now)

- start Firescript

- start HoseLS

- start saw

- start inferno-fire-ems-pager

- start inferno-fire-alarm

- start inferno-ladders 

- FireExplosion (not full done)

add exec "resources/[Firescript addons]\inferno-fire-ems-pager/inferno-fire-ems-pager.cfg" to server.cfg

# Credits


- Albo1125 and foregz - gimicze

# thanks to https://github.com/inferno-collection for make Addons

# LondonStudios for make HoseLS

# If using ESX

1, go to config.lua line 18 and 30


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

