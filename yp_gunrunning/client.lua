--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--Script locals
local blipDrop = nil

--ESX init
ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)


local dropSpots = {{x = 3797.2785, y = 4482.0312, z = 5.9926, active = false},
				   {x = -1592.8800, y = 5223.5708, z = 3.9811, active = false},
				   {x = -3267.8266, y = 957.6707, z = 8.3471, active = false},
				   {x = -177.1099, y = 6550.2592, z = 11.0980, active = false}}



--Functions
function getActiveDrops()
	for i, v in ipairs(dropSpots) do
		if v.active then
			return v, i
		end
	end
	return nil
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--Events

RegisterNetEvent('yp_gunrunning:clearDrop')
AddEventHandler('yp_gunrunning:clearDrop', function(drop)
	dropSpots[drop].active = false
end)

RegisterNetEvent('yp_gunrunning:activateDrop')
AddEventHandler('yp_gunrunning:activateDrop', function(dropNum)
	dropSpots[dropNum].active = true
end)

RegisterNetEvent('yp_gunrunning:notifyPlayer')
AddEventHandler('yp_gunrunning:notifyPlayer', function(dropNum)

	blipDrop = AddBlipForCoord(dropSpots[dropNum].x, dropSpots[dropNum].y, dropSpots[dropNum].z)
    SetBlipSprite(blipDrop , 161)
    SetBlipScale(blipDrop , 2.0)
    SetBlipColour(blipDrop, 3)
    PulseBlip(blipDrop)
end)

RegisterNetEvent('yp_gunrunning:removeBlip')
AddEventHandler('yp_gunrunning:removeBlip', function()
	RemoveBlip(blipDrop)
	blipDrop = nil
end)

--Main Thread
Citizen.CreateThread(function()
	while true do
		local activeDrop, dropNumber = getActiveDrops()
		local playerPed = GetPlayerPed(-1)
		local playerPos = GetEntityCoords(playerPed)

		if Vdist(playerPos.x, playerPos.y, playerPos.z, -2510.4206, 783.2438, 303.3995) < 20 then
			DrawMarker(1, -2510.4206, 782.7438, 302.3995, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if activeDrop ~= nil then
			if Vdist(playerPos.x, playerPos.y, playerPos.z, activeDrop.x, activeDrop.y, activeDrop.z) < 0.5 then
				DisplayHelpText('Press ~INPUT_CONTEXT~ to grab hidden weapons')
				if IsControlJustPressed(0,51) then
					TriggerServerEvent('yp_gunrunning:grabWeapons', dropNumber)
				end
			end
		else

			if Vdist(playerPos.x, playerPos.y, playerPos.z, -2510.4206, 783.2438, 303.3995) < 3 then
				DisplayHelpText('Press ~INPUT_CONTEXT~ to order weapons($' .. cost .. ')')
				if IsControlJustPressed(0,51) then
					TriggerServerEvent('yp_gunrunning:orderWeapons')
				end
			end
		end
		Citizen.Wait(0)
	end
end)

