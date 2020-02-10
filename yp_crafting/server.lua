--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_crafting:getInvData')
AddEventHandler('yp_crafting:getInvData', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local inv = xPlayer.inventory
	local prints = {}

	for i, v in ipairs(inv) do
		if ((string.find(v.name, 'print') ~= nil) and v.count > 0) then
			table.insert(prints, {value = v.name, label = v.label})
		end
	end

	TriggerClientEvent('yp_crafting:startCraftingMenu', src, prints)

end)

RegisterServerEvent('yp_crafting:craftItem')
AddEventHandler('yp_crafting:craftItem', function(item, recipe)
	local xPlayer = ESX.GetPlayerFromId(source)
	local canCraft = true
	for i, v in ipairs(recipe) do
		if xPlayer.getInventoryItem(v.item).count < v.count then
			canCraft = false;
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You do not have enough ' .. v.item , length = 2500})
		end
	end

	if canCraft then
		for i, v in ipairs(recipe) do
			xPlayer.removeInventoryItem(v.item, v.count)
		end

		if string.find(item, 'WEAPON') ~= nil then
			xPlayer.addWeapon(item, 0)
		else
			xPlayer.addInventoryItem(item, 1)
		end
	end
end)

RegisterServerEvent('yp_crafting:getResearch')
AddEventHandler('yp_crafting:getResearch', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local data = {}
	for i, v in ipairs(prints) do
		if xPlayer.getInventoryItem(v).count == 0 then
			table.insert(data, {label = v, value = v})
		end
	end
	TriggerClientEvent('yp_crafting:openResearchMenu', source, data)
end)