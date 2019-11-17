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

RegisterServerEvent('yp_addons:send911Info')
AddEventHandler('yp_addons:send911Info', function(pos, args)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {--Get Data to be displayed on ID
			['@identifier'] = xPlayer.identifier }, function(result)
          	local xPlayers = ESX.GetPlayers()
          	local name = result[1].firstname .. ' ' .. result[1].lastname
			for i, v in ipairs(xPlayers) do
				local xPlayer = ESX.GetPlayerFromId(v)
				if xPlayer.job.name == 'police' or xPlayer.job.name == 'ems' then
					TriggerClientEvent('yp_addons:create911Blip', v, name, pos, args)
				end
			end
          
          TriggerClientEvent('yp_police:viewId', src, data)--Send Data Back to client for display
      end)
	
end)

RegisterServerEvent('yp_addons:buyItemBM')
AddEventHandler('yp_addons:buyItemBM', function(item, amount, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item).count + amount <= xPlayer.getInventoryItem(item).limit then
		if xPlayer.getMoney() >= amount * price then
			xPlayer.addInventoryItem(item, amount)
			xPlayer.removeMoney(amount * price)
			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'success', text = 'You purchased $' .. amount * price .. ' worth of items', length = 2500})
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You cannot afford this!', length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = 'You cannot hold that many!', length = 2500})
	end
end)

ESX.RegisterUsableItem('trafficcone', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('trafficcone', 1)
	TriggerClientEvent('yp_addons:placeCone', source)
end)

ESX.RegisterUsableItem('cigpack', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cigs = xPlayer.getInventoryItem('cigarette').count
	local maxCigs = xPlayer.getInventoryItem('cigarette').limit
	if cigs + 20 <= maxCigs then
		xPlayer.removeInventoryItem('cigpack', 1)
		xPlayer.addInventoryItem('cigarette', 20)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You aleady have opened cigarettes' , length = 2500})

	end
end)

RegisterCommand('911', function(source, args)
	TriggerClientEvent('yp_addons:find911Blip', source, args)
end)


