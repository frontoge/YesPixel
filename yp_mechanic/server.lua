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

RegisterServerEvent('yp_mechanic:getSocietyMoney')
AddEventHandler('yp_mechanic:getSocietyMoney', function()
	local src = source
	MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @name', {['@name'] = 'society_mechanic'}, 
		function(result)
			local amount = result[1].money
			TriggerClientEvent('yp_mechanic:updateSocietyBalance', src, amount)
		end)
end)

RegisterServerEvent('yp_mechanic:withdrawSociety')
AddEventHandler('yp_mechanic:withdrawSociety', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = tonumber(amount)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
		account.removeMoney(amount)
	end)
	xPlayer.addAccountMoney('bank', amount)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = 'You have withdrawn $' .. amount, length=2500})
end)

RegisterServerEvent('yp_mechanic:depositSociety')
AddEventHandler('yp_mechanic:depositSociety', function(amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = tonumber(amount)
	local depositAmount = amount

	if xPlayer.getAccount("bank").money >= amount then
		xPlayer.removeAccountMoney('bank', amount)
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type= 'inform', text= 'You have deposited $' .. amount, length=2500})
	elseif xPlayer.getAccount('bank').money ~= 0 then
		local newAmount = xPlayer.getAccount('bank').money
		depositAmount = newAmount
		xPlayer.removeAccountMoney('bank', newAmount)
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = 'You have deposited $' .. newAmount, length=2500})
	else
		depositAmount = 0
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'erorr', text = 'Your bank is empty', length=2500})
	end

	if depositAmount > 0 then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(depositAmount)
		end)
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