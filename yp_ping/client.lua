--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local listening = false
local accepted = false
local src = -1

local blip = nil

RegisterNetEvent('yp_ping:requestPing')
AddEventHandler('yp_ping:requestPing', function(sender)
	Citizen.CreateThread(function()
		exports['mythic_notify']:DoHudText('inform', 'Ping request from ' .. sender .. ' /accept to accept', 10000)
		src = sender
		listening = true
		Citizen.Wait(15000)
		listening = false
		src = -1
	end)
	
end)

RegisterNetEvent('yp_ping:addBlip')
AddEventHandler('yp_ping:addBlip', function(pos)
	if blip then
		RemoveBlip(blip)
	end
	blip = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blip, 8)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 5)
	SetBlipAsShortRange(blip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Ping")
	EndTextCommandSetBlipName(blip)
	Citizen.CreateThread(function()
		Citizen.Wait(60*1000)
		RemoveBlip(blip)
	end)
end)

RegisterCommand('accept', function(source, args)
	if listening then
		local pos = GetEntityCoords(GetPlayerPed(-1))
		TriggerServerEvent('yp_ping:sendLocation', src, pos)
	end
end, false)

RegisterCommand('model', function(source, args)
	local veh = GetVehiclePedIsIn(GetPlayerPed(-1))
	print(GetEntityModel(veh))
end)