--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local isSpectating = false
local origin = {}

RegisterNetEvent('yp_admin:getTargetCoords')
AddEventHandler('yp_admin:getTargetCoords', function(src)
	--local ped = GetPlayerPed(-1)
	TriggerServerEvent('yp_admin:sendTargetCoords', src, PlayerId())
end)

RegisterNetEvent('yp_admin:startSpectating')
AddEventHandler('yp_admin:startSpectating', function(ped)
	Citizen.CreateThread(function()
		origin = GetEntityCoords(GetPlayerPed(-1))
		isSpectating = true
		SetEntityVisible(GetPlayerPed(-1), false, false)
		Citizen.Wait(1000)
		SetEntityCollision(GetPlayerPed(-1), false, false)
		while isSpectating do
			AttachEntityToEntity(GetPlayerPed(-1), GetPlayerPed(ped), 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			Citizen.Wait(0)
		end
		DetachEntity(GetPlayerPed(-1), true, false)
		SetEntityCoords(GetPlayerPed(-1), origin.x, origin.y, origin.z, 1, 0, 0, 1)
		SetEntityCollision(GetPlayerPed(-1), true, true)
		Citizen.Wait(1000)
		SetEntityVisible(GetPlayerPed(-1), true, false)
	end)
	
end)

RegisterCommand('stopspec', function(source, args)
	if isSpectating then
		isSpectating = false
	else
		exports['mythic_notify']:DoHudText('inform', 'You are not spectating.', 3000)
	end
end)
