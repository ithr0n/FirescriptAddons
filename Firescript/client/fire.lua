--================================--
--       FIRE SCRIPT v1.7.2       --
--  by GIMI (+ foregz, Albo1125)  --
--  make some function ny Wick	  --
--      License: GNU GPL 3.0      --
--================================--

Fire = {
	active = {},
	removed = {},
	__index = self,
	init = function(o)
		o = o or {active = {}, removed = {}}
		setmetatable(o, self)
		self.__index = self
		return o
	end
}

function Fire:createFlame(fireIndex, flameIndex, coords)
	if not self.removed[fireIndex] then
		if self.active[fireIndex] == nil then
			self.active[fireIndex] = {
				flameCoords = {},
				flames = {},
				particles = {},
				flameParticles = {}
			}
        end
		self.active[fireIndex].flameCoords[flameIndex] = coords
	end
end

function Fire:removeFlame(fireIndex, flameIndex)
	if not (fireIndex and flameIndex and self.active[fireIndex]) then
		return
	end
	if self.active[fireIndex].flames[flameIndex] and self.active[fireIndex].flames[flameIndex] > -1 then
		RemoveScriptFire(self.active[fireIndex].flames[flameIndex])
        self.active[fireIndex].flames[flameIndex] = nil
    end
	if self.active[fireIndex].particles[flameIndex] and self.active[fireIndex].particles[flameIndex] ~= 0 then
		local particles = self.active[fireIndex].particles[flameIndex]
		Citizen.SetTimeout(
			5000,
			function()
				StopParticleFxLooped(particles, false)
				RemoveParticleFx(particles, true)
			end
		)
		self.active[fireIndex].particles[flameIndex] = nil
	end
	if self.active[fireIndex].flameParticles[flameIndex] and self.active[fireIndex].flameParticles[flameIndex] ~= 0 then
		local flameParticles = self.active[fireIndex].flameParticles[flameIndex]
		Citizen.SetTimeout(
			5000,
			function()
				StopParticleFxLooped(flameParticles, false)
				RemoveParticleFx(flameParticles, true)
			end
		)
		self.active[fireIndex].flameParticles[flameIndex] = nil
	end
	self.active[fireIndex].flameCoords[flameIndex] = nil

	if self.active[fireIndex] ~= nil and countElements(self.active[fireIndex].flames) < 1 then
		self.active[fireIndex] = nil
		self.removed[fireIndex] = true
	end
end

function Fire:remove(fireIndex, callback)
	if not (self.active[fireIndex] and self.active[fireIndex].particles) then
		return
	end

	for k, v in pairs(self.active[fireIndex].flames) do
        self:removeFlame(fireIndex, k)
        Citizen.Wait(20)
	end

	Citizen.SetTimeout(
		200,
		function()
			if self.active[fireIndex] and next(self.active[fireIndex].flames) ~= nil then
				print("ADVARSEL: En brand vedvarede!")
				self:remove(fireIndex)
			elseif callback then
				callback(fireIndex)
			end
		end
	)
end

function Fire:removeAll(callback)
	for k, v in pairs(self.active) do
		self:remove(k)
        Citizen.Wait(20)
	end

	self.active = {}
	self.removed = {}
	
	if callback then
		callback()
	end
end

--================================--
-- PARTICLES & FIRE EXTINGUISHING --
--================================--

Citizen.CreateThread(
	function()
		if not HasNamedPtfxAssetLoaded("scr_agencyheistb") then
			RequestNamedPtfxAsset("scr_agencyheistb")
			while not HasNamedPtfxAssetLoaded("scr_agencyheistb") do
				Wait(1)
			end
		end

        if not HasNamedPtfxAssetLoaded("scr_trevor3") then
            RequestNamedPtfxAsset("scr_trevor3")
            while not HasNamedPtfxAssetLoaded("scr_trevor3") do
                Wait(1)
            end
		end
		
		while true do
			Citizen.Wait(1500)
			for fireIndex, v in pairs(Fire.active) do
				if countElements(v.particles) ~= 0 then
					for flameIndex, _v in pairs(v.particles) do
						local isFirePresent = GetNumberOfFiresInRange(
							v.flameCoords[flameIndex].x,
							v.flameCoords[flameIndex].y,
							v.flameCoords[flameIndex].z,
							0.05
						)
						if isFirePresent == 0 then
							TriggerServerEvent('fireManager:removeFlame', fireIndex, flameIndex)
						end
					end
				end
			end
		end
	end
)

Citizen.CreateThread(
	function()
		while true do
			local pedCoords = GetEntityCoords(GetPlayerPed(-1))
			while syncInProgress do
				Citizen.Wait(10)
			end
			for fireIndex, v in pairs(Fire.active) do
				for flameIndex, coords in pairs(Fire.active[fireIndex].flameCoords) do
					Citizen.Wait(10)
					if not syncInProgress and Fire.active[fireIndex] and Fire.active[fireIndex].flameCoords[flameIndex] and not Fire.active[fireIndex].particles[flameIndex] and #(coords - pedCoords) < 300.0 then
						local z = coords.z
		
						repeat
							Wait(0)
							ground, newZ = GetGroundZFor_3dCoord(coords.x, coords.y, z, 1)
							if not ground then
								z = z + 0.1
							end
						until ground
						z = newZ
	
						Fire.active[fireIndex].flames[flameIndex] = StartScriptFire(coords.x, coords.y, z, 0, false)

						if Fire.active[fireIndex].flames[flameIndex] then -- Make sure the fire has been spawned properly
							Fire.active[fireIndex].flameCoords[flameIndex] = vector3(coords.x, coords.y, z)
		
							SetPtfxAssetNextCall("scr_agencyheistb")
							
							Fire.active[fireIndex].particles[flameIndex] = StartParticleFxLoopedAtCoord(
								"scr_env_agency3b_smoke",
								Fire.active[fireIndex].flameCoords[flameIndex].x,
								Fire.active[fireIndex].flameCoords[flameIndex].y,
								Fire.active[fireIndex].flameCoords[flameIndex].z + 1.0,
								0.0,
								0.0,
								0.0,
								1.0,
								false,
								false,
								false,
								false
							)
						
							SetPtfxAssetNextCall("scr_trevor3")
						
							Fire.active[fireIndex].flameParticles[flameIndex] = StartParticleFxLoopedAtCoord(
								"scr_trev3_trailer_plume",
								Fire.active[fireIndex].flameCoords[flameIndex].x,
								Fire.active[fireIndex].flameCoords[flameIndex].y,
								Fire.active[fireIndex].flameCoords[flameIndex].z + 1.2,
								0.0,
								0.0,
								0.0,
								1.0,
								false,
								false,
								false,
								false
							)
	
						else
							Fire.active[fireIndex].flames[flameIndex] = nil
						end
					end
				end
			end
			Citizen.Wait(1500)
		end
	end
)

--- VARIABLES ---
-----------------
--local MaxFireLimit = Config.MaxFlames
--local AlreadySpawned = false
local FlameID = nil
local FireActive = false
--local SmokeActive = false
local Fires = {}
--local SmokeOnly = {}
local FireArea
local FireRadius

RegisterNetEvent('fireClient:StartFireClient')
AddEventHandler('fireClient:StartFireClient', function(firetable) 
    StopFireInRange(firetable[1].coords, 100.0)
    Wait(700) 
    for i=1, #firetable, 1 do
        Wait(0)
        print(firetable[i].coords)
        local ground, groundz = GetGroundZFor_3dCoord(firetable[i].coords.x, firetable[i].coords.y, firetable[i].coords.z, 0)
        print(tostring(groundz))
        if ground ~= 0 then -- Double check we are not making fires below ground which may result in fires not being able to be put out
            StartFire(firetable[i].coords)
            FireArea = firetable[i].coords
            if i == #firetable then
                -- prevent increase and decrease of PTFX at same time --
                Wait(#firetable * 1000)
                FireActive = true
            end 
        end
    end
end)

--- Start the main fire ---
function StartFire(FlamePos)
    Citizen.CreateThread(function()
        LoadPTFX('scr_trevor3')
        FlameID = StartScriptFire(FlamePos, 25, true)
        local FlamePTFX = StartParticleFxLoopedAtCoord("scr_trev3_trailer_plume", FlamePos, 0, 0, 0, 0.001, true, true, true, false)
        RemoveNamedPtfxAsset("scr_trevor3")
        SetParticleFxLoopedAlpha(FlamePTFX, 0.85)
        table.insert(Fires, {
            coords = FlamePos,
            handle = FlamePTFX,
            scriptfire = FlameID
        })
        StartUp(FlamePTFX)
    end)
end

--- Startup fire effect ---
function StartUp(handle)
    CreateThread(function()
        if handle ~= nil then
            local size = 0.01
            while size > 0 do
                Citizen.Wait(50)
                SetParticleFxLoopedScale(handle, size)
                if size < 0.65 then
                    size = size + 0.005
                else
                    break
                end
            end
        end
    end)
end

-- Fire timeout trigger --
RegisterNetEvent('fireClient:FireTimeout')
AddEventHandler('fireClient:FireTimeout', function()  
    FireActive = false
    FireTimeout()
end)

RegisterNetEvent('fireClient:GetCoords')
AddEventHandler('fireClient:GetCoords', function(position, flames, radius)  
    FireRadius = radius
    local FireSetup = {}
    for i=1, flames, 1 do
        local FlamePos = GetAround(position, 0, radius)
        local ground, groundz = GetGroundZFor_3dCoord(FlamePos.x, FlamePos.y, FlamePos.z, 0)
        if groundz > 1.0 then
            table.insert(FireSetup, {
                coords = vec3(FlamePos.x, FlamePos.y, groundz + 0.1),
            })
        end
    end
    TriggerServerEvent('fireServer:ReturnCoords', FireSetup)
end)