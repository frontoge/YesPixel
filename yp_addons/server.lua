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
	local src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {--Get Data to be displayed on ID
			['@identifier'] = xPlayer.identifier }, function(result)
          	local xPlayers = ESX.GetPlayers()
          	local name = result[1].firstname .. ' ' .. result[1].lastname
			for i, v in ipairs(xPlayers) do
				local xPlayer = ESX.GetPlayerFromId(v)
				if xPlayer.job.name == 'police' or xPlayer.job.name == 'ems' then
					TriggerClientEvent('yp_addons:create911Blip', v, name, src, pos, args)
				end
			end
        
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

RegisterCommand('911r', function(source, args)
	if not args[1] then return end

	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'ems' or xPlayer.job.name == 'police' or xPlayer.job.name == 'dispatch' then
		TriggerClientEvent('chat:addMessage', args[1], {color = {255, 0, 0}, multiline = true, args = {"Dispatch: ", table.concat(args, ' ', 2)}})
		local xPlayers = ESX.GetPlayers()
		for i, v in pairs(xPlayers) do
			local player = ESX.GetPlayerFromId(v)
			if player.job.name == 'police' or player.job.name == 'ems' or player.job.name == 'dispatch' then
				TriggerClientEvent('chat:addMessage', v, {color = {255, 0, 0}, multiline = true, args = {"Dispatch: (To " .. args[1] .. ")" , table.concat(args, ' ', 2)}})
			end
		end
		
	end
end)

ESX.RegisterUsableItem('arAmmo', function(source)
	TriggerClientEvent('yp_addons:addAmmo', source, 'arAmmo')
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('arAmmo', 1)
end)

ESX.RegisterUsableItem('pAmmo', function(source)
	TriggerClientEvent('yp_addons:addAmmo', source, 'pAmmo')
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('pAmmo', 1)
end)

ESX.RegisterUsableItem('smgAmmo', function(source)
	TriggerClientEvent('yp_addons:addAmmo', source, 'smgAmmo')
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('smgAmmo', 1)
end)

ESX.RegisterUsableItem('sgAmmo', function(source)
	TriggerClientEvent('yp_addons:addAmmo', source, 'sgAmmo')
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('sgAmmo', 1)
end)

ESX.RegisterUsableItem('breathalyzer', function(source)
	TriggerClientEvent('yp_addons:giveBACTest', source)
end)

RegisterServerEvent('yp_addons:BAC:requestDrunk')
AddEventHandler('yp_addons:BAC:requestDrunk', function(target)
	TriggerClientEvent('yp_addons:BAC:getDrunk', target, source)
end)

RegisterServerEvent('yp_addons:BAC:sendDrunk')
AddEventHandler('yp_addons:BAC:sendDrunk', function(target, value)
	local BAC = 0.0
	if value.val ~= 0 then BAC = 0.01 end
	BAC = BAC + (0.4 / 1000000 * value.val)
	BAC = math.floor(BAC * 1000)
	BAC = BAC / 1000
	TriggerClientEvent('mythic_notify:client:SendAlert', target, {type = 'inform', text = 'Their BAC is: ' .. BAC .. '%', length = 4000})
end)



