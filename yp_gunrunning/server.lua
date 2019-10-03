--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local playerOrdered = -1
local dropCount = 4
local onOrder = false

--Events
RegisterServerEvent('yp_gunrunning:grabWeapons')
AddEventHandler('yp_gunrunning:grabWeapons', function(dropNumber)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local dropSet = math.random(1,100)
	local weaponParts = {}

	if dropSet <= 40 then
		weaponParts = pistolParts
	elseif dropSet <= 70 then
		weaponParts = shotgunParts
	elseif dropSet <= 90 then
		weaponParts = smgParts
	else
		weaponParts = arParts
	end


	local totalParts = {}
	for i = 0, #weaponParts, 1 do
		table.insert(totalParts, 0)
	end

	for i = 0, dropAmount, 1 do
		local part = math.random(1, #weaponParts)
		totalParts[part] = totalParts[part] + 1
	end

	for i, v in ipairs(totalParts) do
		if v ~= 0 then
			xPlayer.addInventoryItem(weaponParts[i], v)
		end
	end


	TriggerClientEvent('yp_gunrunning:clearDrop', -1, dropNumber)
	TriggerClientEvent('yp_gunrunning:removeBlip', playerOrdered)
	onOrder = false
	playerOrdered = -1
end)

RegisterServerEvent('yp_gunrunning:orderWeapons')
AddEventHandler('yp_gunrunning:orderWeapons', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getMoney() >= cost then
		if not onOrder then
			playerOrdered = src
			xPlayer.removeMoney(cost)
			local dropNum = math.random(1, dropCount)
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'A weapon shipment will arrive in ' .. dropTime .. ' minutes', length = 2500})
			Citizen.CreateThread(function()
				Citizen.Wait(dropTime * 60000)
				TriggerClientEvent('yp_gunrunning:activateDrop', -1, dropNum)
				TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'The weaponShipment is now available', length = 2500})
			end)
			TriggerClientEvent('yp_gunrunning:notifyPlayer', src, dropNum)
			onOrder = true
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There is already a shipment on the way', length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have enough money', length = 2500})
	end
end)