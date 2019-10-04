--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_addons:buyVendItem')
AddEventHandler('yp_addons:buyVendItem', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= vendingCost then
		xPlayer.removeMoney(vendingCost)
		xPlayer.addInventoryItem(item, 1)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have enough money for this...' , length = 2500})
	end

end)

ESX.RegisterUsableItem('trafficcone', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('trafficcone', 1)
	TriggerClientEvent('yp_addons:placeCone', source)
end)

