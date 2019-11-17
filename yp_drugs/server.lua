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

RegisterServerEvent('yp_drugs:cookMeth')
AddEventHandler('yp_drugs:cookMeth', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local bat = xPlayer.getInventoryItem('carbattery').count > 0
	local meds = xPlayer.getInventoryItem('coldmeds').count > 0
	local flare = xPlayer.getInventoryItem('roadflare').count > 0

	local canMake = true

	if not flare then
		canMake = false
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You need Phosphorus', length = 2500})
	end

	if not bat then
		canMake = false
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You need Lithium', length = 2500})
	end

	if not meds then
		canMake = false
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You need Sudafed', length = 2500})
	end

	if canMake then
		xPlayer.removeInventoryItem('carbattery', 1)
		xPlayer.removeInventoryItem('coldmeds', 1)
		xPlayer.removeInventoryItem('roadflare', 1)
		TriggerClientEvent('yp_drugs:crafting:makeMeth', source)
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

ESX.RegisterUsableItem('cigarette', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cigarette', 1)
	TriggerClientEvent('yp_drugs:actions:useCigarette', source)
end)

ESX.RegisterUsableItem('heroin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('heroin', 1)
	TriggerClientEvent('yp_drugs:actions:useHeroin', source)
end)

ESX.RegisterUsableItem('xanax', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('xanax', 1)
	TriggerClientEvent('yp_drugs:actions:useXanax', source)
end)

ESX.RegisterUsableItem('vicodin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicodin', 1)
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