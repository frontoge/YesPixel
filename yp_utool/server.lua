--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_utool:checkout')
AddEventHandler('yp_utool:checkout', function(card, total, items)
	local xPlayer = ESX.GetPlayerFromId(source)
	local canBuy = false
	local enoughRoom = true
	if items['repairs'] + xPlayer.getInventoryItem('repairkit').count > xPlayer.getInventoryItem('repairkit').limit then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You can not hold that many repair kits!', length = 2500})
		enoughRoom = false
	end

	if items['radios'] + xPlayer.getInventoryItem('radio').count > xPlayer.getInventoryItem('radio').limit then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You can not hold that many radios!', length = 2500})
		enoughRoom = false
	end

	if items['flares'] + xPlayer.getInventoryItem('roadflare').count > xPlayer.getInventoryItem('roadflare').limit then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You can not hold that many road flares!', length = 2500})
		enoughRoom = false
	end

	if items['pliers'] + xPlayer.getInventoryItem('pliers').count > xPlayer.getInventoryItem('pliers').limit then
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You can not hold that many pliers!', length = 2500})
		enoughRoom = false
	end

	if enoughRoom then
		if card then
			if xPlayer.getAccount('bank').money >= total then
				xPlayer.removeAccountMoney('bank', total)
				canBuy = true
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Your card was declined.', length = 2500})
			end
		else
			if xPlayer.getMoney() >= total then
				xPlayer.removeMoney(total)
				canBuy = true
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = "You don't have enough cash.", length = 2500})
			end
		end

		if canBuy then
			if items['repairs'] then
				xPlayer.addInventoryItem('repairkit', items['repairs'])
			end
			
			if items['radios'] then
				xPlayer.addInventoryItem('radio', items['radios'])
			end

			if items['flares'] then
				xPlayer.addInventoryItem('roadflare', items['flares'])
			end

			if items['pliers'] then
				xPlayer.addInventoryItem('pliers', items['pliers'])
			end

			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = "You purchased items for $" .. total, length = 2500})
			exports['yp_taxes']:applyTax(source, 'sales', total)
		end
	end
end)