--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_mechanic:craftRepairKit')
AddEventHandler('yp_mechanic:craftRepairKit', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local total = 0
	local canCraft = true

	while total < amount do
		canCraft = true
		for i, v in pairs(AdvancedKit) do
			if xPlayer.getInventoryItem(i).count < v * (total + 1) then
				canCraft = false
				TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You do not have enough ' .. i, length = 2500})
			end
		end
		if canCraft then
			total = total + 1
			print(count)
		else
			break
		end
	end

	if total > 0 then
		xPlayer.addInventoryItem('advrepair', total)
		xPlayer.removeInventoryItem('metal', AdvancedKit['metal'] * total)
		xPlayer.removeInventoryItem('carbattery', AdvancedKit['carbattery'] * total)
		xPlayer.removeInventoryItem('electronics', AdvancedKit['electronics'] * total)
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = 'You crafted ' .. total .. ' repair kits', length = 2500})
	end

end)

RegisterServerEvent('yp_mechanic:chargePlayer')
AddEventHandler('yp_mechanic:chargePlayer', function(target, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local targetPlayer = ESX.GetPlayerFromId(target)

	targetPlayer.removeAccountMoney('bank', amount)
	xPlayer.addAccountMoney('bank', amount * 0.75)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
		account.addMoney(amount * 0.25)
	end)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = 'You recieved a payment of $' .. amount * 0.75, length=2500})
	TriggerClientEvent('mythic_notify:client:SendAlert', target, {type = 'inform', text = 'You made a payment of $' .. amount, length=2500})
	exports['yp_taxes']:applyTax(source, 'income', amount)
	exports['yp_taxes']:applyTax(target, 'sales', amount)
end)

RegisterServerEvent('yp_mechanic:chargeForRepair')
AddEventHandler('yp_mechanic:chargeForRepair', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeAccountMoney('bank', amount)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
		account.addMoney(amount)
	end)
	exports['yp_taxes']:applyTax(source, 'sales', amount)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = 'You made a payment of $' .. amount .. ' for repairs', length=2500})
end)

ESX.RegisterUsableItem('advrepair', function(source)
	TriggerClientEvent('yp_mechanic:repairEngine', source)
end)