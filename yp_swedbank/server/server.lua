--Config Locals
local cooldownMax = 2 * 60
local copsMin = 1

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Script Locals
local doors = {true, true, true, true, true, true}--Status of doorlocks
local cooldown = cooldownMax
local onCooldown = false
local beingRobbed = false
local copsOn = 0
local firstAction = true
local robbers = {}
local vaultRotation = 160.0

--Fucntions
function isRobber(id)
	for i = 1, #robbers, 1 do
		if robbers[i] == id then
			return true
		end
	end
	return false
end

function startCooldown()
	onCooldown = true
	Citizen.CreateThread(function()
		while cooldown > 0 do
			cooldown = cooldown - 1
			Citizen.Wait(1000)
		end
		vaultRotation = 160.0
		TriggerClientEvent('yp_swedbank:resetClient', -1)
		firstAction = true
		copsOn = 0
		cooldown = cooldownMax
		onCooldown = false
		robbers = {}
		for i = 1, #doors, 1 do
			doors[i] = true
		end
	end)
end

--Events
RegisterServerEvent('yp_swedbank:getDoorStatus')
AddEventHandler('yp_swedbank:getDoorStatus', function()
	TriggerClientEvent('yp_swedbank:initDoors', source, doors, vaultRotation)
end)

RegisterServerEvent('yp_swedbank:startLockpick')
AddEventHandler('yp_swedbank:startLockpick', function(doorNum)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if firstAction then--Get Cops on if this is the first action performed in the bank.
		firstAction = false
		local xPlayers = ESX.GetPlayers()
		for i = 1, #xPlayers, 1 do
			local player = ESX.GetPlayerFromId(xPlayers[i])
			if player.job.name == 'police' then
				copsOn = copsOn + 1
			end
		end
	end
	
	if xPlayer.getInventoryItem('lockpick').count > 0 then
		if not onCooldown then
			if copsOn >= copsMin then
				TriggerClientEvent('yp_swedbank:lockpick', src, doorNum)
				if not beingRobbed then
					beingRobbed = true
					TriggerEvent('yp_swedbank:tripAlarm')
				end
				if not isRobber(src) then
					table.insert(robbers,src)
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There needs to be at least '.. copsMin .. ' cops on to rob the bank' , length = 2500})
				copsOn = 0
				firstAction = true
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. cooldown .. 's' , length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a lockpick!' , length = 2500})
	end
end)

RegisterServerEvent('yp_swedbank:startHack')
AddEventHandler('yp_swedbank:startHack', function(doorNum)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if xPlayer.getInventoryItem('brutedrive').count > 0 then
		if not onCooldown then
			if not isRobber(src) then
				table.insert(robbers, src)
			end
			TriggerClientEvent('yp_swedbank:hack', src, doorNum)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. cooldown .. 's' , length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a Brute Force Drive!' , length = 2500})
	end
end)

RegisterServerEvent('yp_swedbank:tripAlarm')
AddEventHandler('yp_swedbank:tripAlarm', function()
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('yp_swedbank:createBlip', xPlayers[i])
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'Swedbank is being robbed!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
		end
	end
end)

RegisterServerEvent('yp_swedbank:consumePick')
AddEventHandler('yp_swedbank:consumePick', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('lockpick', 1)
end)

RegisterServerEvent('yp_swedbank:finishPick')
AddEventHandler('yp_swedbank:finishPick', function(doorNum)
	doors[doorNum] = false
	TriggerClientEvent('yp_swedbank:unlockDoor', -1, doorNum)
end)

RegisterServerEvent('yp_swedbank:leaveStore')
AddEventHandler('yp_swedbank:leaveStore', function()
	local src = source
	if beingRobbed then
		local src = source
		if isRobber(src) then
			TriggerEvent('yp_swedbank:killAlarm')
			beingRobbed = false
			startCooldown()
		end
	end
end)

RegisterServerEvent('yp_swedbank:killAlarm')
AddEventHandler('yp_swedbank:killAlarm', function()
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'Robbery at Swedbank has been cancelled!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
			TriggerClientEvent('yp_swedbank:stopBlip', xPlayers[i])
		end
	end
	for i, v in ipairs(robbers) do
		TriggerClientEvent('mythic_notify:client:SendAlert', v, { type = 'success', text = 'You robbed Swedbank!' , length = 2500})
	end
end)

RegisterServerEvent('yp_swedbank:pickingActive')
AddEventHandler('yp_swedbank:pickingActive', function(doorNum)
	TriggerClientEvent('yp_swedbank:startPicking', -1, doorNum)
end)

RegisterServerEvent('yp_swedbank:pickingStopped')
AddEventHandler('yp_swedbank:pickingStopped', function(doorNum)
	TriggerClientEvent('yp_swedbank:stopPicking', -1, doorNum)
end)

RegisterServerEvent('yp_swedbank:searchDrawer')
AddEventHandler('yp_swedbank:searchDrawer', function(searchNum)
	TriggerClientEvent('yp_swedbank:startSearch', source, searchNum)
	TriggerClientEvent('yp_swedbank:makeSearched', -1, searchNum)
end)

RegisterServerEvent('yp_swedbank:cashDrawerDrop')
AddEventHandler('yp_swedbank:cashDrawerDrop', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local payout = math.random(1500, 2250)
	xPlayer.addAccountMoney('black_money', payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'You got $' .. payout .. ' black money!' , length = 2500})
end)

RegisterServerEvent('yp_swedbank:setRotation')
AddEventHandler('yp_swedbank:setRotation', function(rotationVal)
	vaultRotation = rotationVal
end)

RegisterServerEvent('yp_swedbank:startThermite')
AddEventHandler('yp_swedbank:startThermite', function(drillNum)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getInventoryItem('thermite').count > 0 then
		if not onCooldown then
			if not isRobber(src) then
				table.insert(robbers,src)
			end
			TriggerClientEvent('yp_swedbank:thermiteGame', src, drillNum)
			xPlayer.removeInventoryItem('thermite', 1)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. cooldown .. 's' , length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a Thermite Torch' , length = 2500})
	end
end)

RegisterServerEvent('yp_swedbank:drillingActive')
AddEventHandler('yp_swedbank:drillingActive', function(drillNum)
	TriggerClientEvent('yp_swedbank:startDrilling', -1, drillNum)
end)

RegisterServerEvent('yp_swedbank:drillingStopped')
AddEventHandler('yp_swedbank:drillingStopped', function(drillNum)
	TriggerClientEvent('yp_swedbank:stoptDrilling', -1, drillNum)
end)

RegisterServerEvent('yp_swedbank:finishDrilling')
AddEventHandler('yp_swedbank:finishDrilling', function(drillNum)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local payout = math.random(70000,100000)
	xPlayer.addAccountMoney('black_money', payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = 'You got $' .. payout .. ' black money!' , length = 2500})
	TriggerClientEvent('yp_swedbank:drillBox', -1, drillNum)
end)
