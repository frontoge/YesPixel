--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local onCooldown = false
local maxCooldown = 20*60
local cooldownTime = 5*60


--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--Function 
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function doCooldown()
	Citizen.CreateThread(function()
		onCooldown = true
		while cooldownTime > 0 do
			Citizen.Wait(1000)
			cooldownTime = cooldownTime - 1
		end
		cooldownTime = maxCooldown
		onCooldown = false
	end)
end


--Main Thread
Citizen.CreateThread(function()
	Citizen.Wait(500)
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		if Vdist(pos.x, pos.y, pos.z, 2351.7304, 3133.9331, 47.7715) < 20 then -- Car Return
			DrawMarker(1, 2351.7304, 3133.9331, 47.2715, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.5, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
		end

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = ESX.Game.GetClosestVehicle()
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				if Vdist(pos.x, pos.y, pos.z, 2351.7304, 3134.9331, 47.7715) < 3 then
					DisplayHelpText("Press ~INPUT_CONTEXT~ to chop this vehicle")
					if IsControlJustPressed(0,51) then
						if not onCooldown then
							local class = GetVehicleClass(vehicle)
							TriggerServerEvent('yp_chopshop:chopVehicle', class, GetVehicleNumberPlateText(vehicle))
							ESX.Game.DeleteVehicle(vehicle)
							doCooldown()
						else
							exports['mythic_notify']:DoHudText('error', 'You have already chopped a vehicle, come back in ' .. cooldownTime .. ' seconds')
						end
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)
