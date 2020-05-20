--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('armor', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem('armor').count > 0 then
		xPlayer.removeInventoryItem('armor', 1)
		TriggerClientEvent('yp_extraitems:useItem', source, 'armor')
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text="You do not have any body armor", length=3000})
	end
end)