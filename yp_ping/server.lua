--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

RegisterCommand('ping', function(source, args)
	if args[1] ~= nil then
		TriggerClientEvent('yp_ping:requestPing', args[1], source)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'Specify a player id', length=2500})
	end
end, false)

RegisterServerEvent('yp_ping:sendLocation')
AddEventHandler('yp_ping:sendLocation', function(target, pos)
	TriggerClientEvent('yp_ping:addBlip', target, pos)
end)