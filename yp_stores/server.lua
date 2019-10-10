--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_stores:checkout')
AddEventHandler('yp_stores:checkout', function(paymentType, cart, cost)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local canAfford = false

	if paymentType == 'card' then
		if xPlayer.getAccountMoney('bank') >= cost then
			xPlayer.removeAccountMoney('bank', cost)
			canAfford = true
		end
	else
		if xPlayer.getMoney() >= cost then
			xPlayer.removeMoney(cost)
			canAfford = true
		end
	end

	if canAfford then
		for i, v in ipairs(cart) do
			xPlayer.addInventoryItem(cart.item, cart.count)
		end
		exports['yp_taxes']:applyTax(src, 'sales', cost)
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = 'Checkout complete!', length = 2500})
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You cannot afford this purchase', length = 2500})
	end


end)