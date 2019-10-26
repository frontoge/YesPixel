--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_drugs:buyFromDispensary')
AddEventHandler('yp_drugs:buyFromDispensary', function(item, amount, cost, card)
	local canBuy = false
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count + amount < xPlayer.getInventoryItem(item).limit and xPlayer.getInventoryItem(item).limit ~= -1 then
		if card then
			if xPlayer.getAccount('bank').money >= cost then
				xPlayer.removeAccountMoney('bank', cost)
				canBuy = true
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Your card was declined.', length = 2500})
			end
		else
			if xPlayer.getMoney() >= cost then
				xPlayer.removeMoney(cost)
				canBuy = true
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You do not have enough cash.', length = 2500})
			end
		end

		if canBuy then
			xPlayer.addInventoryItem(item, amount)
			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = 'You bought items for $' .. cost, length = 2500})
			exports['yp_taxes']:applyTax(source, 'sales', cost)
		end

	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You cannot carry that much', length = 2500})
	end
end)

ESX.RegisterUsableItem('cocaine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cocaine', 1)
	TriggerClientEvent('yp_drugs:actions:useCocaine', source)
end)

ESX.RegisterUsableItem('meth', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('meth', 1)
	TriggerClientEvent('yp_drugs:actions:useMeth', source)
end)

ESX.RegisterUsableItem('joint', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('joint', 1)
	TriggerClientEvent('yp_drugs:actions:useJoint', source)
end)

ESX.RegisterUsableItem('blunt', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('blunt', 1)
	TriggerClientEvent('yp_drugs:actions:useBlunt', source)
end)

ESX.RegisterUsableItem('heroin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('heroin', 1)
	TriggerClientEvent('yp_drugs:actions:useHeroin')
end)

ESX.RegisterUsableItem('xanax', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('xanax', 1)
	TriggerClientEvent('yp_drugs:actions:useXanax', source)
end)

ESX.RegisterUsableItem('vicoidn', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicoidn', 1)
	TriggerClientEvent('yp_drugs:actions:useVicodin', source)
end)

ESX.RegisterUsableItem('lsd', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('lsd', 1)
	TriggerClientEvent('yp_drugs:actions:useLSD', source)
end)

ESX.RegisterUsableItem('rollingpapers', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem('weed').count >= 1 then
		xPlayer.removeInventoryItem('weed', 1)
		xPlayer.removeInventoryItem('rollingpapers', 1)
		TriggerClientEvent('yp_drugs:actions:rollWeed', source, 'joint')
	end
end)

ESX.RegisterUsableItem('cigarillo', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem('weed').count >= 2 then
		xPlayer.removeInventoryItem('weed', 1)
		xPlayer.removeInventoryItem('cigarillo', 1)
		TriggerClientEvent('yp_drugs:actions:rollWeed', source, 'blunt')
	end
end)