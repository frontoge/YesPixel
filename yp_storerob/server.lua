--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('yp_storerob:alertPolice')
AddEventHandler('yp_storerob:alertPolice', function(store, storeIndex)
	TriggerClientEvent('yp_storerob:startRobbery', -1, storeIndex)

	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = store.name .. ' is being robbed!' , length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
			TriggerClientEvent('yp_storerob:addBlip', xPlayers[i], store.safe, storeIndex)
		end
	end
end)

RegisterServerEvent('yp_storerob:payoutRegister')
AddEventHandler('yp_storerob:payoutRegister', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local payout = math.random(250, 500)

	xPlayer.addMoney(payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You robbed the register and got $' .. payout , length = 3000})

end)

RegisterServerEvent('yp_storerob:updateRegisterState')
AddEventHandler('yp_storerob:updateRegisterState', function(store, register)
	TriggerClientEvent('yp_storerob:toggleRegister', -1, store, register)
end)

RegisterServerEvent('yp_storerob:updateRobbery')
AddEventHandler('yp_storerob:updateRobbery', function(store)
	TriggerClientEvent('yp_storerob:addRobber', -1, source, store)
end)

RegisterServerEvent('yp_storerob:updateRobbery')
AddEventHandler('yp_storerob:updateRobbery', function(store, src)
	TriggerClientEvent('yp_storerob:addRobber', -1, src, store)
end)

RegisterServerEvent('yp_storerob:startSafeRob')
AddEventHandler('yp_storerob:startSafeRob', function(storeIndex, store)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getInventoryItem('lockpick').count > 0 then
		TriggerClientEvent('yp_storerob:lockpickSafe', src, storeIndex)
		TriggerClientEvent('yp_storerob:disableSafe', -1, storeIndex)
		TriggerEvent('yp_storerob:updateRobbery', storeIndex, src)
		if not store.beingRobbed then
			TriggerEvent('yp_storerob:alertPolice', store, storeIndex)
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You do not have a lockpick!' , length = 3000})
	end
end)

RegisterServerEvent('yp_storerob:payoutSafe')
AddEventHandler('yp_storerob:payoutSafe', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local payout = math.random(1800, 2375)

	xPlayer.addMoney(payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You robbed the safe and got $' .. payout , length = 3000})
end)

RegisterServerEvent('yp_storerob:failedSafe')
AddEventHandler('yp_storerob:failedSafe', function(store)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('lockpick', 1)
	TriggerClientEvent('yp_storerob:enableSafe', -1, store)
end)

RegisterServerEvent('yp_storerob:endRob')
AddEventHandler('yp_storerob:endRob', function(storeIndex, store)
	local isRobber = false
	for i, v in ipairs(store.robbers) do
		if source == v then
			isRobber = true
			break;
		end
	end
	if isRobber then
		TriggerClientEvent('yp_storerob:endRob', -1, storeIndex)
		for i, v in ipairs(store.robbers) do
			print(v)
			TriggerClientEvent('mythic_notify:client:SendAlert', v, { type = 'success', text = 'You robbed ' .. store.name .. '!' , length = 3000})
		end

		local xPlayers = ESX.GetPlayers()
		for i = 1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				TriggerClientEvent('yp_storerob:endBlip', xPlayers[i], storeIndex)
			end	
		end
	end

end)