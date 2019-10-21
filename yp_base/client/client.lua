--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local frozen = false

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

--Events
RegisterNetEvent('yp_base:disableHPRegen')
AddEventHandler('yp_base:disableHPRegen', function()
	local playerPed = GetPlayerPed(-1)
	SetPlayerHealthRechargeMultiplier(playerPed, 0.0)
end)

RegisterNetEvent('yp_base:freezePlayer')
AddEventHandler('yp_base:freezePlayer', function()
	FreezePlayer()
end)

RegisterNetEvent('yp_base:unFreezePlayer')
AddEventHandler('yp_base:unFreezePlayer', function()
	UnFreezePlayer()
end)

Citizen.CreateThread(function()
	while true do
		if frozen then
			DisableControlAction(0, 32, true) --W
			DisableControlAction(0, 33, true) --S
			DisableControlAction(0, 34, true) --A
			DisableControlAction(0, 35, true) --D
			DisableControlAction(0, 73, true) --X
		end
		Citizen.Wait(0)
	end
end)