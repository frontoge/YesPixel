--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Events
RegisterServerEvent('yp_police:startJobMenu')
AddEventHandler('yp_police:startJobMenu', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.job.name == 'police' then
		TriggerClientEvent('yp_police:openJobMenu', src)
	end
end)

RegisterServerEvent('yp_police:cuffPlayer')
AddEventHandler('yp_police:cuffPlayer', function(target)
	TriggerClientEvent('yp_userinteraction:getcuffed', target)
end)

RegisterServerEvent('yp_police:uncuffPlayer')
AddEventHandler('yp_police:uncuffPlayer', function(targer)
	TriggerClientEvent('yp_userinteraction:getuncuffed', target)
end)

RegisterServerEvent('yp_police:escort')
AddEventHandler('yp_police:escort', function(target)
	local src = source
	TriggerClientEvent('yp_userinteraction:escort', target, src)
end)