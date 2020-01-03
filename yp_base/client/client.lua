--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local frozen = false
local newStress = 0
local lastStress = -1

--Functions
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function FreezePlayer()
	frozen = true
end

function UnFreezePlayer()
	frozen = false
end

function addStress(amount)
	newStress = newStress + amount
end

function removeStress(amount)
	TriggerEvent('esx_status:getStatus', 'stress', function(status)
		if status.val - amount < 0 then
			TriggerEvent('esx_status:set', 'stress', 0)
		else
			TriggerEvent('esx_status:set', 'stress', status.val - amount)
		end
	end)
end

function deleteVehicle(entity)
	Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end

--Events
RegisterNetEvent('yp_base:disableHPRegen')
AddEventHandler('yp_base:disableHPRegen', function()
end)

RegisterNetEvent('yp_base:freezePlayer')
AddEventHandler('yp_base:freezePlayer', function()
	FreezePlayer()
end)

RegisterNetEvent('yp_base:unFreezePlayer')
AddEventHandler('yp_base:unFreezePlayer', function()
	UnFreezePlayer()
end)

--Stress Status
local stressed = false

AddEventHandler('esx_status:loaded', function(status)

	TriggerEvent('esx_status:registerStatus', 'stress', 0, '#CF2F0F', function(status)
		return false
	end, function(status)
		status.remove(0)

	end)
end)

--Thread for screen shaking
Citizen.CreateThread(function()
	while true do
		TriggerEvent('esx_status:getStatus', 'stress', function(status)--Check if the player has stress
			if status.val ~= lastStress then 
				if status.val >= 150000 then--Set the stressed value accordingly
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.25)
				elseif status.val >= 300000 then
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.5)
				elseif status.val >= 500000 then
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.75)
				elseif status.val >= 750000 then
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.0)
				end
				lastStress = status.val
			end
		end)
		Citizen.Wait(12000)--Run the loop once per 12 seconds
	end
end)

--Main Thread (once per tick)
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
		if frozen then
			DisableControlAction(0, 32, true) --W
			DisableControlAction(0, 33, true) --S
			DisableControlAction(0, 34, true) --A
			DisableControlAction(0, 35, true) --D
			DisableControlAction(0, 73, true) --X
		end

		if IsPedShooting(playerPed) then
			addStress(math.random(100,250))
		end

		if newStress ~= 0 then
			TriggerEvent("esx_status:add", 'stress', newStress)
			newStress = 0
		end

		Citizen.Wait(0)
	end
end)