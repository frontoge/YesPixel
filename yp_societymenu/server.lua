--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_societymenu:getSocietyMoney')
AddEventHandler('yp_societymenu:getSocietyMoney', function(society)
	local src = source
	MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @name', {['@name'] = society}, 
		function(result)
			local amount = result[1].money
			TriggerClientEvent('yp_societymenu:updateSocietyBalance', src, amount, society)
		end)
end)

RegisterServerEvent('yp_societymenu:withdrawSociety')
AddEventHandler('yp_societymenu:withdrawSociety', function(amount, society)
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = tonumber(amount)
	TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
		account.removeMoney(amount)
	end)
	xPlayer.addAccountMoney('bank', amount)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = 'You have withdrawn $' .. amount, length=2500})
end)

RegisterServerEvent('yp_societymenu:depositSociety')
AddEventHandler('yp_societymenu:depositSociety', function(amount, society)
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
		TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
			account.addMoney(depositAmount)
		end)
	end
end)