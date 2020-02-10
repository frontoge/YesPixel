--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Init BankData
local bankData = {}
Citizen.CreateThread(function()
	for i, v in ipairs(Banks) do
		local hacks = {}
		local drills = {}
		local registers = {}

		if v.hacks ~= nil then
			for i2, v2 in ipairs(v.hacks) do
				table.insert(hacks, false)
			end
		end

		if v.drills ~= nil then
			for i2, v2 in ipairs(v.drills) do
				table.insert(drills, false)
			end
		end

		if v.registers ~= nil then
			for i2, v2 in ipairs(v.registers) do
				table.insert(registers, false)
			end
		end

		table.insert(bankData, {hacks = hacks, drills = drills, registers = registers, counterDoor = false, cooldown = CooldownMax * 60, onCooldown = false, beingRobbed = false})

	end
end)

local robbers = {}
local robberyCount = 0

--Functions
function isRobber(id)
	for i, v in ipairs(robbers) do
		if v == id then
	  		return true
		end
  	end
  return false
end

function canRob()
	local xPlayers = ESX.GetPlayers()
	local cops = 0
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			cops = cops + 1
		end
	end
	if cops >= CopsMin and robberyCount == 0 then
		robberyCount = 1
		return true
	else
		return false
	end
end

function tripAlarm(bankInd)
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'reporter' then
			TriggerClientEvent('yp_bankrob:createAlarmBlip', xPlayers[i], bankInd)
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = Banks[bankInd].name .. ' is being robbed!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
		end
	end
end

function endpolice(bankInd)
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'reporter' then
			TriggerClientEvent('yp_bankrob:removeBlip', xPlayers[i])
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = Banks[bankInd].name .. ' has been robbed!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
		end
	end
end

function notifyPlayers(bankInd)
	for i = 1, #robbers, 1 do
		if isRobber(robbers[i]) then
			TriggerClientEvent('mythic_notify:client:SendAlert', robbers[i], {type = 'success', text = 'You robbed ' .. Banks[bankInd].name .. '!', length = 2500})
		end
	end
end

function startCooldown(bankInd)
	bankData[bankInd].onCooldown = true
	Citizen.CreateThread(function()
		while bankData[bankInd].cooldown > 0 do
			bankData[bankInd].cooldown = bankData[bankInd].cooldown - 1
			Citizen.Wait(1000)
		end
		bankData[bankInd].onCooldown = false
		bankData[bankInd].cooldown = CooldownMax * 60
		--ResetBank
		bankData[bankInd].counterDoor = false
		TriggerClientEvent('yp_bankrob:closeDoor', -1, bankInd, 0)

		for i, v in ipairs(bankData[bankInd].registers) do
			v = false
		end

		for i, v in ipairs(bankData[bankInd].hacks) do
			bankData[bankInd].hacks[i] = false
			TriggerClientEvent('yp_bankrob:closeDoor', -1, bankInd, i)
		end

		for i, v in ipairs(bankData[bankInd].drills) do
			v = false
		end


	end)
end

--Events
RegisterServerEvent('yp_bankrob:startHack')
AddEventHandler('yp_bankrob:startHack', function(bankInd, hackInd)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not bankData[bankInd].hacks[hackInd] then
		if xPlayer.getInventoryItem('brutedrive').count > 0 then
			if not bankData[bankInd].onCooldown then
				local enoughCops = canRob()
				if not bankData[bankInd].beingRobbed then
					if enoughCops then
						tripAlarm(bankInd)

						bankData[bankInd].beingRobbed = true

					else
						TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The terminal is off.' , length = 2500})
					end
				end

				if enoughCops or bankData[bankInd].beingRobbed then
					if not isRobber(src) then
						table.insert(robbers, src)
						TriggerClientEvent('yp_bankrob:becomeRobber', src)
					end

					bankData[bankInd].hacks[hackInd] = true
					TriggerClientEvent('yp_bankrob:hack', src, bankInd, hackInd)
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. bankData[bankInd].cooldown .. 's' , length = 2500})
			end

		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a brute force drive!' , length = 2500})
		end

	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This terminal has already been hacked!' , length = 2500})
	end
end)

RegisterServerEvent('yp_bankrob:startPick')
AddEventHandler('yp_bankrob:startPick', function(bankInd)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not bankData[bankInd].counterDoor then
		if xPlayer.getInventoryItem('lockpick').count > 0 then
			if not bankData[bankInd].onCooldown then
				local enoughCops = canRob()
				if not bankData[bankInd].beingRobbed then
					if enoughCops then
						tripAlarm(bankInd)

						bankData[bankInd].beingRobbed = true
					else
						TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The door seems to be sealed.' , length = 2500})
					end
				end

				if enoughCops or bankData[bankInd].beingRobbed then
					if not isRobber(src) then
						table.insert(robbers, src)
						TriggerClientEvent('yp_bankrob:becomeRobber', src)
					end

					bankData[bankInd].counterDoor = true
					TriggerClientEvent('yp_bankrob:lockpick', src, bankInd)
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. bankData[bankInd].cooldown .. 's' , length = 2500})
			end

		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a lockpick!' , length = 2500})
		end

	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This door is already unlocked!' , length = 2500})
	end
end)

RegisterServerEvent('yp_bankrob:startRegister')
AddEventHandler('yp_bankrob:startRegister', function(bankNum, registerNum)
	local src = source

	if not bankData[bankNum].registers[registerNum] then
		if not bankData[bankNum].onCooldown then
			bankData[bankNum].registers[registerNum] = true
			if not isRobber(src) then
				table.insert(robbers, src)
				TriggerClientEvent('yp_bankrob:becomeRobber', src)
			end
			TriggerClientEvent('yp_bankrob:robRegister', src)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. bankData[bankNum].cooldown .. 's' , length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This register is empty!' , length = 2500})

	end
end)

RegisterServerEvent('yp_bankrob:startThermite')
AddEventHandler('yp_bankrob:startThermite', function(bankNum, drillNum)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not bankData[bankNum].drills[drillNum] then
		if not bankData[bankNum].onCooldown then
			if xPlayer.getInventoryItem('thermite').count > 0 then
				bankData[bankNum].drills[drillNum] = true
				if not isRobber(src) then
					table.insert(robbers, src)
					TriggerClientEvent('yp_bankrob:becomeRobber', src)
				end
				TriggerClientEvent('yp_bankrob:thermite', src, bankNum, drillNum)
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a thermite torch!' , length = 2500})
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The bank has already been robbed, come back in ' .. bankData[bankNum].cooldown .. 's' , length = 2500})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This box has already been drilled!' , length = 2500})

	end
end)

RegisterServerEvent('yp_bankrob:payoutRegister')
AddEventHandler('yp_bankrob:payoutRegister', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local payout = math.random(400, 600)
	xPlayer.addMoney(payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'success', text = 'You grabbed $' .. payout, length = 2500})
end)

RegisterServerEvent('yp_bankrob:finishDrilling')
AddEventHandler('yp_bankrob:finishDrilling', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local index = math.random(1, #Drops)
	local dropItem = Drops[index].item
	local dropAmount = math.random(Drops[index].lower, Drops[index].upper)

	if dropItem == 'cash' then
		xPlayer.addMoney(dropAmount)
	else
		xPlayer.addInventoryItem(dropItem, dropAmount)
	end

	TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'success', text = 'You stole ' .. dropAmount .. ' ' .. dropItem .. '(s)', length = 2500})
end)

RegisterServerEvent('yp_bankrob:consumeDrive')
AddEventHandler('yp_bankrob:consumeDrive', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('brutedrive', 1)
end)

RegisterServerEvent('yp_bankrob:consumePick')
AddEventHandler('yp_bankrob:consumePick', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('lockpick', 1)
end)

RegisterServerEvent('yp_bankrob:consumeThermite')
AddEventHandler('yp_bankrob:consumeThermite', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('thermite', 1)
end)

RegisterServerEvent('yp_bankrob:unHack')
AddEventHandler('yp_bankrob:unHack', function(bankInd, hackInd)
	bankData[bankInd].hacks[hackInd] = false
end)

RegisterServerEvent('yp_bankrob:unPick')
AddEventHandler('yp_bankrob:unPick', function(bankInd)
	bankData[bankInd].counterDoor = false
end)

RegisterServerEvent('yp_bankrob:unDrill')
AddEventHandler('yp_bankrob:unDrill', function(bankInd, drillNum)
	bankData[bankInd].drills[drillNum] = false
end)

RegisterServerEvent('yp_bankrob:updateDoors')
AddEventHandler('yp_bankrob:updateDoors', function(bank)
	
	if bankData[bank].hacks[1] then
		TriggerClientEvent('yp_bankrob:openDoor', source, bank, 1)
	else
		TriggerClientEvent('yp_bankrob:closeDoor', source, bank, 1)
	end

	if bankData[bank].hacks[2] then
		TriggerClientEvent('yp_bankrob:openDoor', source, bank, 2)
	else
		TriggerClientEvent('yp_bankrob:closeDoor', source, bank, 2)
	end

	if bankData[bank].counterDoor then
		TriggerClientEvent('yp_bankrob:openDoor', source, bank, 0)
	else
		TriggerClientEvent('yp_bankrob:closeDoor', source, bank, 0)
	end

end)

RegisterServerEvent('yp_bankrob:updateDoorStatus')
AddEventHandler('yp_bankrob:updateDoorStatus', function(bank, doorNum)
	TriggerClientEvent('yp_bankrob:openDoor', -1, bank, doorNum)
end)

RegisterServerEvent('yp_bankrob:endRob')
AddEventHandler('yp_bankrob:endRob', function(bankInd)
	if bankData[bankInd].beingRobbed then
		bankData[bankInd].beingRobbed = false
		startCooldown(bankInd)
		endpolice(bankInd)
		notifyPlayers(bankInd)
		robberyCount = robberyCount - 1
	end
end)
