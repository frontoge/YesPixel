--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local playerOrdered = -1

--Events
RegisterServerEvent('yp_gunrunning:grabWeapons')
AddEventHandler('yp_gunrunning:grabWeapons', function(dropNumber)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.addInventoryItem('wrapped_pistol', 10)

	TriggerClientEvent('yp_gunrunning:clearDrop', -1, dropNumber)
	TriggerClientEvent('yp_gunrunning:removeBlip', playerOrdered)
	playerOrdered = -1
end)

RegisterServerEvent('yp_gunrunning:orderWeapons')
AddEventHandler('yp_gunrunning:orderWeapons', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getMoney() >= cost then
		xPlayer.removeMoney(cost)
		local dropNum = math.rand(1, dropCount)
		TriggerClientEvent('mythic_notify:client:SendAlert', robbers[i], { type = 'inform', text = 'A weapon shipment will arrive in ' .. dropTime .. ' minutes', length = 2500})
		Citizen.CreateThread(function()
			Citizen.Wait(dropTime * 60000)
			TriggerClientEvent('yp_gunrunning:activateDrop', -1, dropCount)
			TriggerClientEvent('yp_gunrunning:notifyPlayer', src, dropCount)
			TriggerClientEvent('mythic_notify:client:SendAlert', robbers[i], { type = 'inform', text = 'The weaponShipment is now available', length = 2500})
		end)
		playerOrdered = src
	else

	end
end)