--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_utool:getLimits')
AddEventHandler('yp_utool:getLimits', function(conf)
	local xPlayer = ESX.GetPlayerFromId(source)

	local updatedItems = {}

	for i, v in pairs(conf) do
		local item = xPlayer.getInventoryItem(i)
		updatedItems[i] = v
		updatedItems[i].limit = item.limit - item.count
		if updatedItems[i].limit < 0 then updatedItems[i].limit = 0 end
	end

	TriggerClientEvent('yp_utool:sendLimits', source, updatedItems)
end)

RegisterServerEvent('yp_utool:checkout')
AddEventHandler('yp_utool:checkout', function(items, price, card)
	local xPlayer = ESX.GetPlayerFromId(source)
	if card then
		if xPlayer.getAccount('bank').money >= price then
			xPlayer.removeAccountMoney('bank', price)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Not Enough in your bank.', length = 4000})
			return
		end
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Not Enough cash.', length = 4000})
			return
		end
	end

	for i, v in pairs(items) do
		if v > 0 then
			xPlayer.addInventoryItem(i, v)
		end
	end
	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = 'Purchase Successful. You paid $' .. price, length = 4000})
	TriggerClientEvent('yp_utool:clear', source)

end)
