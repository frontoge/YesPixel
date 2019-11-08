
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('radio', function(source, args)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'police' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'fib' then
		if args[1] ~= 'disc' then
			TriggerClientEvent('yp_radio:joinRadio', source, tonumber(args[1]))
		else
			TriggerClientEvent('yp_radio:leaveRadio', source)
		end
	end
end)