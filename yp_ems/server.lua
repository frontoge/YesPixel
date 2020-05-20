--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil
local ems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_ems:revivePlayer')
AddEventHandler('yp_ems:revivePlayer', function(target)
	TriggerClientEvent('esx_ambulancejob:revive', target)
end)

RegisterServerEvent('yp_ems:payForItems')
AddEventHandler('yp_ems:payForItems', function(card, amount, item, price)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local canAfford = false

	if card then
		if xPlayer.getAccount('bank').money >= price then
			xPlayer.removeAccountMoney('bank', price)
			canAfford = true
		end
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
			canAfford = true
		end
	end



	if canAfford then
		xPlayer.addInventoryItem(item, amount)
		exports['yp_taxes']:applyTax(src, 'sales', price)
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = 'Checkout for $' .. price .. ' complete!', length = 2500})
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You cannot afford this purchase', length = 2500})
	end
end)

RegisterServerEvent('yp_ems:sendLocation')
AddEventHandler('yp_ems:sendLocation', function(player, src)
     local players = ems
     for i, v in pairs(players) do
          MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {['@identifier'] = ESX.GetPlayerFromId(src).identifier},
               function(result)
                    local name = result[1].firstname .. ' ' .. result[1].lastname --get players name that went on duty
                    TriggerClientEvent('yp_ems:recieveLocation', i, player, name)
               end)
     end
end)

RegisterServerEvent('yp_ems:onDuty')
AddEventHandler('yp_ems:onDuty', function(player)
     ems[source] = player
     TriggerEvent('yp_ems:sendLocation', player, source)
     local src = source
     for i, v in pairs(ems) do--Get the locations of all the other ems on duty
          MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {['@identifier'] = ESX.GetPlayerFromId(i).identifier},
                function(result)
                    local name = result[1].firstname .. ' ' .. result[1].lastname --get players name that went on duty
                    TriggerClientEvent('yp_police:recieveLocation', src, v, name)
                end)
     end
end)

RegisterServerEvent('yp_ems:offDuty')
AddEventHandler('yp_ems:offDuty', function(player)
     ems[source] = nil
     for i, v in pairs(ems) do
          TriggerClientEvent('yp_ems:removePlayer', i, player)
          TriggerClientEvent('yp_ems:removePlayer', source, v)
     end
end)

RegisterServerEvent('yp_ems:escort')
AddEventHandler('yp_ems:escort', function(target)
	local src = source
	TriggerClientEvent('yp_userinteraction:escort', target, src)
end)

RegisterCommand('cpr', function(source, args)
	local xPlayers = ESX.GetPlayers()
	local chance = false
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		local job = xPlayer.job.name
		if job == 'ems' then
			chance = true
			break			
		end
	end
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'ems' or xPlayer.job.name == 'police' then chance = false end
	TriggerClientEvent('yp_ems:doCPR', source, chance)
end)

