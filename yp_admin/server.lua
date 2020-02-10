--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

RegisterServerEvent('yp_admin:sendTargetCoords')
AddEventHandler('yp_admin:sendTargetCoords', function(src, ped)
	TriggerClientEvent('yp_admin:startSpectating', src, ped)
end)

RegisterCommand('spec', function(source, args)
	local target = args[1]
	TriggerClientEvent('yp_admin:getTargetCoords', target, source)
end, true)