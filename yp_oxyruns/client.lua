ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

local pedspawns = {
  {x = 146.45, y =  192.93,  z = 106.49}, --Next to Big Bank
  {x = -1410.67, y = -208.28, z = 46.99},  --Near Del Perro Theatre
  {x = -1235.53, y = -1393.51, z = 4.11},  --Near Mask Shop
  {x = 480.5, y = -1860.2, z = 27.38}, --Near JamesTown
  {x = 1143.99, y = -998.57, z = 45.41}, --Outside ot Store at 7539
  {x =  47.61, y = -1315.1,  z = 29.27}, --Near Strawberry Store
  {x = -82.85, y = -280.38, z = 45.55}, --Backside of Clothin store at 171
  {x = -667.58, y = -968.6,  z = 21.03}, --Little Seoul
  {x = 1094.26, y = -774.5,  z = 58.2}, --Near Mirror Park Garage
  {x = 1263.84, y = -1602.2, z = 53.16}, --In Fudge Lane near 7529
  {x = 174.87, y = -1803.75, z = 29.25}, --Near Grove Street
  {x = -1460.73, y = -392.26, z = 38.22}, --Behind Store at 116
  {x = -784.3, y = 269.87, z = 85.8} --Near Eclipse Towers
}

local isRunActive = false
local onCooldown = false
local cooldowntime = 30000 --in miliseconds
local Pedinsession = {}
local blips = {}
local tyringToBuy = false


Citizen.CreateThread(function()
	while true do 
	local playerPed = GetPlayerPed(-1)
	local pos = GetEntityCoords(playerPed)
	local dist = Vdist(pos.x, pos.y, pos.z, -44.29, -1547.3, 34.62)
	if dist < 10 then 
		DrawMarker(27, -44.29, -1547.3, 33.65, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.00, 1.00, 1.0, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
		if dist < 0.5 then 
			exports['yp_base']:DisplayHelpText('Press E to buy some oxy')
			if IsControlJustPressed(0, 51) then
				if not onCooldown and not isRunActive and not tryingToBuy then
						TriggerServerEvent('yp_oxyruns:checkitem')
				else 
					exports['mythic_notify']:DoHudText('inform', 'No one is looking for Oxy')
				end
			end
		end
	end
	Citizen.Wait(0)
end
end)


function LoadModel(model)
    while not HasModelLoaded(model) do
          RequestModel(model)
          Citizen.Wait(10)
    end
end



RegisterNetEvent('Bolls')
AddEventHandler('Bolls', function()
	Citizen.CreateThread(function()

		LoadModel('ig_russiandrunk')

		local targets = {}
		for i = 1, 10, 1 do
		  local duplicate
		  local index
		  repeat
		    duplicate = false
		    index = math.random(1, #pedspawns)
		    for i, v in pairs(targets) do
		        if v == pedspawns[index] then
		            duplicate = true
		        end
		    end
		  until not duplicate
		  targets[i] = pedspawns[index]
		end

							--[[RequestModel('sultan')
			    			while not HasModelLoaded('sultan') do
        						Citizen.Wait(500)
    					    end
						    	local vehicle = CreateVehicle(GetHashKey('sultan'), -24.89, -1529.53, 30.22, 51.01, true, true)
								exports['EngineToggle']:addKey(GetVehicleNumberPlateText(vehicle))--]]
								

		for index, value in pairs(targets) do
			local Ped = CreatePed(12, GetHashKey('ig_russiandrunk'), value.x, value.y, value.z, 0.0, true, false)
			Pedinsession[index] =  {id = Ped, x = value.x, y = value.y, z = value.z}
			blips[index] = AddBlipForEntity(Ped)
		    SetBlipSprite(blips[index], 51)
		end

		while next(Pedinsession) do

			for index, value in pairs(Pedinsession) do
				if DoesEntityExist(value.id) then
					--print(DoesEntityExist(value.id))
					local pedpos = GetEntityCoords(value.id)
			        local player = GetPlayerPed(-1)
			        local pos = GetEntityCoords(player)
			        local playertoped = GetDistanceBetweenCoords(pos, pedpos, true)
		        --print(playertoped)

					if playertoped <= 1 then
						exports['yp_text']:DrawText3D(pedpos.x, pedpos.y, pedpos.z + 0.5, "E to Sell oxy")
	        			if IsControlJustPressed(0, 51) then 
							TriggerServerEvent('yp_oxyruns:sellOxy', index)
							Citizen.Wait(2000)
							TaskWanderStandard(value.id, 10.0, 10)
							Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(value.id))
	            			--break
	        			end
	    			end
	    		end
			end
			Citizen.Wait(0)
		end

		Citizen.Wait(2500)
		exports['mythic_notify']:DoHudText('success', 'Sold Oxy to all clients')
		TriggerServerEvent('yp_oxyruns:cooldown')
	end)
end)

RegisterNetEvent('removePepega')
AddEventHandler('removePepega', function(index)
	Pedinsession[index] = nil
	print(#Pedinsession)
	RemoveBlip(blips[index])
end)

RegisterNetEvent('yp_oxyruns:client:cooldown')
AddEventHandler('yp_oxyruns:client:cooldown', function()
	Citizen.CreateThread(function()
		onCooldown = true
		Citizen.Wait(cooldowntime)
		onCooldown = false
    end)
end)

RegisterNetEvent('yp_oxyruns:toggleRun')
AddEventHandler('yp_oxyruns:toggleRun', function(state)
	isRunActive = state
end)
