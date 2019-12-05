
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('radio', function(source, args)
	if args[1] ~= 'disc' then
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.getInventoryItem('radio').count > 0 then
			TriggerClientEvent('yp_radio:openRadio', source)
		end
	else
		TriggerClientEvent('yp_radio:leaveRadio', source)
	end
end)