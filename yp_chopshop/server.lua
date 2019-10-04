--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--



--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_chopshop:chopVehicle')
AddEventHandler('yp_chopshop:chopVehicle', function(class, plate)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local droptype = math.random(1,3)
	local drop = nil
	local dropAmount = 0
	if droptype == 1 then
		drop = 'metal'
		dropAmount = dropValues[class].metal
	elseif droptype == 2 then
		drop = 'plastic'
		dropAmount = dropValues[class].plastic
	else
		drop = 'electronics'
		dropAmount = dropValues[class].electronics
	end
	if dropAmount ~= 0 then
		local salt = math.random(1, 2)
		dropAmount = dropAmount + salt
		xPlayer.addInventoryItem(drop, dropAmount)
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = 'You recieved ' .. dropAmount .. ' of ' .. drop .. ' for this vehicle' , length = 2500})
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There was nothing of value in this vehicle...' , length = 2500})
	end

	TriggerEvent('yp_chopshop:checkOwner', plate)

end)

RegisterServerEvent('yp_chopshop:checkOwner')
AddEventHandler('yp_chopshop:checkOwner', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate',{
    ['@plate'] = plate},
    function(result)
        if result[1] ~= nil then
           	if xPlayer.identifier == result[1].owner then
        		TriggerEvent('yp_chopshop:permaVehicle', plate)
        	end
        end
    end)
end)

RegisterServerEvent('yp_chopshop:permaVehicle')
AddEventHandler('yp_chopshop:permaVehicle', function(plate)
	MySQL.Async.fetchAll('DELETE FROM owned_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result) end)
end)
