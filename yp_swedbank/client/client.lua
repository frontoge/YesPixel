--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local bank = {
	startOne = {x = 257.2599, y = 219.9673, z = 106.3239, picked = false, picking = false, model = -222270721},--10750383
	startTwo = {x = 256.5676, y = 207.2012, z = 110.2830, picked = false, picking = false, model = 1956494919},--1250858883
	hack1 = {x = 262.0107, y = 223.2110, z = 106.2844, hacked = false, hacking = false, model = 746855201},--10750383
	hack2 = {x = 253.2644, y = 228.3956, z = 101.6832, hacked = false, hacking = false, model = 961976194},--10750383
	lockpick1 = {x = 253.0929, y = 221.0321, z = 101.6834, picked = false, picking = false, model = -1508355822},
	lockpick2 = {x = 261.2867, y = 215.5632, z = 101.6834, picked = false, picking = false, model = -1508355822},
	drawerOne = {x = 253.1392, y = 222.8825, z = 106.2869, robbed = false, robbing = false},
	drawerTwo = {x = 247.9263, y = 224.7754, z = 106.2872, robbed = false, robbing = false},
	drawerThree = {x = 242.8712, y = 226.6180, z = 106.2874, robbed = false, robbing = false},
	bankersDesk = {x = 261.8909, y = 204.6210, z = 110.2871, searched = false, searching = false},
	drill1 = {x = 259.6196, y = 217.9618, z = 101.6834, drilled = false, drilling = false},
	drill2 = {x = 258.1748, y = 214.1781, z = 101.6834, drilled = false, drilling = false},
	drill3 = {x = 264.6351, y = 216.1394, z = 101.6834, drilled = false, drilling = false},
	drill4 = {x = 266.0463, y = 213.5893, z = 101.6834, drilled = false, drilling = false},
	drill5 = {x = 263.4389, y = 212.3291, z = 101.6834, drilled = false, drilling = false},
	exit = {x = 231.9918, y = 215.3617, z = 106.2864},
	exitSide = {x = 259.4477, y = 203.6972, z = 106.2832}
}
local beingRobbed = false
local playerReady = true
local blipRobbery = nil
local pressed = false
local listening = false
local updatedDoors = false
local bankcard = false

local buttonsPick = {{char = 'Up', value = 172}, {char = 'Down', value = 173}, {char = 'Left', value = 174}, {char = 'Right', value = 175}}
local buttonsHack = {
  {char = 'Z', value = 20}, {char = 'F', value = 49}, {char = 'B', value = 29}, {char = 'H', value = 304}, {char = 'Space', value = 179}, {char = 'K', value = 311},
  {char = 'L', value = 7}, {char = 'M', value = 244}, {char = 'N', value = 306}, {char = 'U', value = 303}, {char = 'Y', value = 246}, {char = 'LShift', value = 21}}

--ESX init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--Funcntions
function resetBank()
	local startOne = bank.startOne
	local startTwo = bank.startTwo
	local hack1 = bank.hack1
	local hack2 = bank.hack2
	local lockpick1 = bank.lockpick1
	local lockpick2 = bank.lockpick2
	--Get object
	local startOneObj = GetClosestObjectOfType(startOne.x, startOne.y, startOne.z, 5.0, startOne.model)
	local startTwoObj = GetClosestObjectOfType(startTwo.x, startTwo.y, startTwo.z, 5.0, startTwo.model)
	local hack1Obj = GetClosestObjectOfType(hack1.x, hack1.y, hack1.z, 5.0, hack1.model)
	local hack2Obj = GetClosestObjectOfType(hack2.x, hack2.y, hack2.z, 20.0, hack2.model)
	local lockpick1Obj = GetClosestObjectOfType(lockpick1.x, lockpick1.y, lockpick1.z, 5.0, lockpick1.model)
	local lockpick2Obj = GetClosestObjectOfType(lockpick2.x, lockpick2.y, lockpick2.z, 5.0, lockpick2.model)
	
	FreezeEntityPosition(startOneObj, true)
	FreezeEntityPosition(startTwoObj, true)
	FreezeEntityPosition(hack1Obj, true)
	SetEntityRotation(hack2Obj, 0.0, 0.0, 160)
	FreezeEntityPosition(hack2Obj, true)
	FreezeEntityPosition(lockpick1Obj, true)
	FreezeEntityPosition(lockpick2Obj, true)
	
	startOne.picked = false
	startTwo.picked = false
	hack1.hacked = false
	hack2.hacked = false
	lockpick1.picked = false
	lockpick2.picked = false
	
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function listenForPress(key)
  Citizen.CreateThread(function()
    while listening do
      if IsControlJustPressed(0, key) then
        pressed = true
      end
      Citizen.Wait(0)
    end
  end)
end

function getDoorFromNum(index)
	if index == 1 then
		return bank.startOne
	elseif index == 2 then
		return bank.startTwo
	elseif index == 3 then
		return bank.hack1
	elseif index == 4 then
		return bank.hack2
	elseif index == 5 then
		return bank.lockpick1
	elseif index == 6 then
		return bank.lockpick2
	else
		print('Attempted to index a nil door index, contact an admin to resolve this issue')
	end
end

--Events
RegisterNetEvent('yp_swedbank:playerReady')
AddEventHandler('yp_swedbank:playerReady', function()
	playerReady = true
	TriggerServerEvent('yp_swedbank:getDoorStatus')
end)

RegisterNetEvent('yp_swedbank:initDoors')
AddEventHandler('yp_swedbank:initDoors', function(doors, rotation)
	if doors[1] then
		local door = GetClosestObjectOfType(bank.startOne.x, bank.startOne.y, bank.startOne.z, 5.0, bank.startOne.model)
		FreezeEntityPosition(door, true)
	end
	if doors[2] then
		local door = GetClosestObjectOfType(bank.startTwo.x, bank.startTwo.y, bank.startTwo.z, 5.0, bank.startTwo.model)
		FreezeEntityPosition(door, true)
	end
	if doors[3] then
		local door = GetClosestObjectOfType(bank.hack1.x, bank.hack1.y, bank.hack1.z, 5.0, bank.hack1.model)
		FreezeEntityPosition(door, true)
	end
	if doors[4] then
		local door = GetClosestObjectOfType(bank.hack2.x, bank.hack2.y, bank.hack2.z, 20.0, bank.hack2.model)
		SetEntityRotation(door, 0.0, 0.0, rotation)
		FreezeEntityPosition(door, true)
	end
	if doors[5] then
		local door = GetClosestObjectOfType(bank.lockpick1.x, bank.lockpick1.y, bank.lockpick1.z, 5.0, bank.lockpick1.model)
		FreezeEntityPosition(door, true)
	end
	if doors[6] then
		local door = GetClosestObjectOfType(bank.lockpick2.x, bank.lockpick2.y, bank.lockpick2.z, 5.0, bank.lockpick2.model)
		FreezeEntityPosition(door, true)
	end
end)



RegisterNetEvent('yp_swedbank:lockpick')
AddEventHandler('yp_swedbank:lockpick', function(doorNum)
	TriggerServerEvent('yp_swedbank:pickingActive', doorNum)
	--Lockpick minigame
	exports['mythic_notify']:DoHudText('inform', 'Lockpicking starting')
	local failed = 0
	local correct = 0
	Citizen.CreateThread(function()--Main Thread for the lockpicking
	Citizen.Wait(2500)
		while failed < 1  and correct < 5 do 
			local letter = math.random(1,4)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsPick[letter].char)
			listening = true
			listenForPress(buttonsPick[letter].value)
			Citizen.Wait(850) --Timer to press Key
			listening = false
			--Parsing the results of the loop
			if pressed then
				correct = correct + 1
				if correct == 1 then
					exports['mythic_notify']:DoShortHudText('success', 'Finding tension')
				elseif correct == 2 then
					exports['mythic_notify']:DoShortHudText('success', 'Found tension')
				elseif correct == 3 then
					exports['mythic_notify']:DoShortHudText('success', 'Raking pins')
				elseif correct == 4 then
					exports['mythic_notify']:DoShortHudText('success', 'Rotating Cylinder')
				else
					exports['mythic_notify']:DoShortHudText('success', 'Door unlocked')
				end
			else
				exports['mythic_notify']:DoShortHudText('error', 'Your Lockpick broke!')
				failed = failed + 1
			end
			pressed = false
			Citizen.Wait(2500)
		end
		if failed == 1 then
			TriggerServerEvent('yp_swedbank:consumePick')
		else
			TriggerServerEvent('yp_swedbank:finishPick', doorNum)
		end
		TriggerServerEvent('yp_swedbank:pickingStopped', doorNum)
	end)
end)

RegisterNetEvent('yp_swedbank:hack')
AddEventHandler('yp_swedbank:hack', function(doorNum)
	exports['mythic_notify']:DoHudText('inform', 'Hacking starting')
	TriggerServerEvent('yp_swedbank:pickingActive', doorNum)
	local failed = 0
	local correct = 0
	Citizen.CreateThread(function()--Main Thread for the hack
		Citizen.Wait(2500)
		while failed < 3  and correct < 10 and not bankcard do 
			local letter = math.random(1,12)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsHack[letter].char)
			listening = true
			listenForPress(buttonsHack[letter].value)
			Citizen.Wait(850) --Timer to press Key
			listening = false
			--Parsing the results of the loop
			if pressed then
				correct = correct + 1
				if correct == 1 then
					exports['mythic_notify']:DoShortHudText('success', 'Started Password Search')
				elseif correct == 2 then
					exports['mythic_notify']:DoShortHudText('success', 'Found Password')
				elseif correct == 3 then
					exports['mythic_notify']:DoShortHudText('success', 'Logging in')
				elseif correct == 4 then
					exports['mythic_notify']:DoShortHudText('success', 'Finding Firewall')
				elseif correct == 5 then
					exports['mythic_notify']:DoShortHudText('success', 'Firewall Found')
				elseif correct == 6 then
					exports['mythic_notify']:DoShortHudText('success', 'Disabling Firewall')
				elseif correct == 7 then
					exports['mythic_notify']:DoShortHudText('success', 'Firewall Disabled')
				elseif correct == 8 then
					exports['mythic_notify']:DoShortHudText('success', 'Checking for Footprints')
				elseif correct == 9 then
					exports['mythic_notify']:DoShortHudText('success', 'Clearing Footprints')
				else
					exports['mythic_notify']:DoShortHudText('success', 'Access Granted')
				end
			else
				failed = failed + 1
				exports['mythic_notify']:DoShortHudText('error', 'Failed to make progress')
			end
			pressed = false
			Citizen.Wait(2500)
		end
		if failed == 3 then
			exports['mythic_notify']:DoShortHudText('error', 'Hacking Failed')
			TriggerServerEvent('yp_bankrob:consumeDrive')
		elseif bankcard then
			TriggerServerEvent('yp_swedbank:finishPick', doorNum)
			exports['mythic_notify']:DoShortHudText('success', 'Access granted with bank card')
		else
			TriggerServerEvent('yp_swedbank:finishPick', doorNum)
		end
		TriggerServerEvent('yp_swedbank:pickingStopped', doorNum)
	end)
end)

RegisterNetEvent('yp_swedbank:startSearch')
AddEventHandler('yp_swedbank:startSearch', function(searchNum)
	local playerPed = GetPlayerPed(-1)
	local searchTime = math.random(20,35)
	Citizen.CreateThread(function()
		TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
		DisableControlAction(0,73,true)
		exports['progressBars']:startUI(searchTime * 1000, "Searching")
		Citizen.Wait(searchTime * 1000)
		ClearPedTasksImmediately(playerPed)
		DisableControlAction(0,73,false)
		if searchNum == 4 then
			local num = math.random(1, 100)
			if num <= 10 then
				exports['mythic_notify']:DoShortHudText('success', 'You found a bank card!')
				bankcard = true
			else
				exports['mythic_notify']:DoShortHudText('error', 'You found nothing of use')
			end
		else
			TriggerServerEvent('yp_swedbank:cashDrawerDrop')
		end
	end)
end)

RegisterNetEvent('yp_swedbank:makeSearched')
AddEventHandler('yp_swedbank:makeSearched', function(searchNum)
	local drawer = nil
	if searchNum == 1 then
		drawer = bank.drawerOne
	elseif searchNum == 2 then
		drawer = bank.drawerTwo
	elseif searchNum == 3 then
		drawer = bank.drawerThree
	else
		drawer = bank.bankersDesk
	end
	
	drawer.searched = true
	
end)

RegisterNetEvent('yp_swedbank:createBlip')
AddEventHandler('yp_swedbank:createBlip', function()
	blipRobbery = AddBlipForCoord(241.0, 220.0, 106.0)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 3)
    PulseBlip(blipRobbery)
end)

RegisterNetEvent('yp_swedbank:startPicking')
AddEventHandler('yp_swedbank:startPicking', function(doorNum)
	local door = getDoorFromNum(doorNum)
	if doorNum ~= 3 and doorNum ~= 4 then
		door.picking = true
	else
		door.hacking = true
	end
end) 

RegisterNetEvent('yp_swedbank:stopPicking')
AddEventHandler('yp_swedbank:stopPicking', function(doorNum)
	local door = getDoorFromNum(doorNum)
	if doorNum ~= 3 and doorNum ~= 4 then
		door.picking = false
	else
		door.hacking = false
	end
end)

RegisterNetEvent('yp_swedbank:unlockDoor')
AddEventHandler('yp_swedbank:unlockDoor', function(doorNum)
	local door = nil
	if doorNum == 1 then
		door = GetClosestObjectOfType(bank.startOne.x, bank.startOne.y, bank.startOne.z, 5.0, bank.startOne.model)
		bank.startOne.picked = true
	elseif doorNum == 2 then
		door = GetClosestObjectOfType(bank.startTwo.x, bank.startTwo.y, bank.startTwo.z, 5.0, bank.startTwo.model)
		bank.startTwo.picked = true
	elseif doorNum == 3 then
		door = GetClosestObjectOfType(bank.hack1.x, bank.hack1.y, bank.hack1.z, 5.0, bank.hack1.model)
		bank.hack1.hacked = true
	elseif doorNum == 4 then
		door = GetClosestObjectOfType(bank.hack2.x, bank.hack2.y, bank.hack2.z, 20.0, bank.hack2.model)
		bank.hack2.hacked = true
	elseif doorNum == 5 then
		door = GetClosestObjectOfType(bank.lockpick1.x, bank.lockpick1.y, bank.lockpick1.z, 5.0, bank.lockpick1.model)
		bank.lockpick1.picked = true
	elseif doorNum == 6 then
		door = GetClosestObjectOfType(bank.lockpick2.x, bank.lockpick2.y, bank.lockpick2.z, 5.0, bank.lockpick2.model)
		bank.lockpick2.picked = true
	end
	FreezeEntityPosition(door, false)
	if doorNum == 4 then
		local rotation = GetEntityRotation(door)["z"]
		local x = 0
		Citizen.CreateThread(function()
			while x < 500 do
				rotation = rotation - 0.25
				SetEntityRotation(door, 0.0, 0.0, rotation)
				x = x + 1
				Citizen.Wait(0)
			end
		end)
		TriggerServerEvent('yp_swedbank:setRotation', rotation)
	end
end)

RegisterNetEvent('yp_swedbank:thermiteGame')
AddEventHandler('yp_swedbank:thermiteGame', function(drillNum)
	TriggerServerEvent('yp_swedbank:drillingActive', drillNum)
	--Lockpick minigame
	exports['mythic_notify']:DoHudText('inform', 'Prepping Thermite')
	local failed = 0
	local correct = 0
	Citizen.CreateThread(function()--Main Thread for the lockpicking
	Citizen.Wait(2500)
		while failed < 1  and correct < 5 do 
			local letter = math.random(1,4)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsPick[letter].char)
			listening = true
			listenForPress(buttonsPick[letter].value)
			Citizen.Wait(850) --Timer to press Key
			listening = false
			--Parsing the results of the loop
			if pressed then
				correct = correct + 1
				if correct == 1 then
					exports['mythic_notify']:DoShortHudText('success', 'Filling Torch')
				elseif correct == 2 then
					exports['mythic_notify']:DoShortHudText('success', 'Pressurizing Oxidization chamber')
				elseif correct == 3 then
					exports['mythic_notify']:DoShortHudText('success', 'Sealing Fuel tank')
				elseif correct == 4 then
					exports['mythic_notify']:DoShortHudText('success', 'Preparing Ignition')
				else
					exports['mythic_notify']:DoShortHudText('success', 'Ignition Successful!')
				end
			else
				exports['mythic_notify']:DoShortHudText('error', 'Thermite Prep Unsuccessful...')
				failed = failed + 1
			end
			pressed = false
			Citizen.Wait(2500)
		end
		if failed ~= 1 then
			local playerPed = GetPlayerPed(-1)
			Citizen.CreateThread(function()
				local drillTime = math.random(10,15)
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				exports['progressBars']:startUI(drillTime * 1000, "Opening Box")
				Citizen.Wait(drillTime * 1000)
				ClearPedTasksImmediately(playerPed)
				TriggerServerEvent('yp_swedbank:finishDrilling', drillNum)
			end)
			
			
		end
		TriggerServerEvent('yp_swedbank:drillingStopped', drillNum)
	end)
end)

RegisterNetEvent('yp_swedbank:startDrilling')
AddEventHandler('yp_swedbank:startDrilling', function(drillNum)
	local drill = nil
	if drillNum == 1 then
		drill = bank.drill1
	elseif drillNum == 2 then
		drill = bank.drill2
	elseif drillNum == 3 then
		drill = bank.drill3
	elseif drillNum == 4 then
		drill = bank.drill4
	else
		drill = bank.drill5
	end
	
	drill.drilling = true
end)

RegisterNetEvent('yp_swedbank:stopDrilling')
AddEventHandler('yp_swedbank:stopDrilling', function(drillNum)
	local drill = nil
	if drillNum == 1 then
		drill = bank.drill1
	elseif drillNum == 2 then
		drill = bank.drill2
	elseif drillNum == 3 then
		drill = bank.drill3
	elseif drillNum == 4 then
		drill = bank.drill4
	else
		drill = bank.drill5
	end
	
	drill.drilling = false
end)

RegisterNetEvent('yp_swedbank:drillBox')
AddEventHandler('yp_swedbank:drillBox', function(drillNum)
	local drill = nil
	if drillNum == 1 then
		drill = bank.drill1
	elseif drillNum == 2 then
		drill = bank.drill2
	elseif drillNum == 3 then
		drill = bank.drill3
	elseif drillNum == 4 then
		drill = bank.drill4
	else
		drill = bank.drill5
	end
	
	drill.drilled = true
end)


RegisterNetEvent('yp_swedbank:stopBlip')
AddEventHandler('yp_swedbank:stopBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('yp_swedbank:resetClient')
AddEventHandler('yp_swedbank:resetClient', function()
	resetBank()
	bankcard = false
end)

--Threads
Citizen.CreateThread(function( ) 
	while not playerReady do -- Hold until yp_base init
		Citizen.Wait(0)
	end
	--declarations for main loop
	local playerPed = GetPlayerPed(-1)
	local pos = nil
	while true do--main loop
		pos = GetEntityCoords(playerPed)
		if Vdist(pos.x, pos.y, pos.z, 241.0, 220.0, 106.0) < 25 and not updatedDoors then
			TriggerServerEvent('yp_swedbank:getDoorStatus')
			updatedDoors = true
		end
		if Vdist(pos.x, pos.y, pos.z, 241.0, 220.0, 106.0) >= 25 then
			updatedDoors = false
		end
		if Vdist(pos.x, pos.y, pos.z, bank.startOne.x, bank.startOne.y, bank.startOne.z) < 0.75 and not bank.startOne.picked and not bank.startOne.picking then--Lockpick of Teller Gate
			DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startLockpick', 1)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.startTwo.x, bank.startTwo.y, bank.startTwo.z) < 0.8 and not bank.startTwo.picked and not bank.startTwo.picking then --Office Door Lockpick
			DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startLockpick', 2)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.hack1.x, bank.hack1.y, bank.hack1.z) < 0.75 and (bank.startOne.picked or bank.startTwo.picked) and not bank.hack1.hacked then --Hack to go downstairs
			DisplayHelpText('Press ~INPUT_CONTEXT~ to hack')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startHack', 3)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drawerOne.x, bank.drawerOne.y, bank.drawerOne.z) < 0.5 and (bank.startOne.picked or bank.startTwo.picked) and not bank.drawerOne.searched then--Cash Drawer 1
			DisplayHelpText('Press ~INPUT_CONTEXT~ to search')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:searchDrawer', 1)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drawerTwo.x, bank.drawerTwo.y, bank.drawerTwo.z) < 0.5 and (bank.startOne.picked or bank.startTwo.picked) and not bank.drawerTwo.searched then--Cash Drawer 2
			DisplayHelpText('Press ~INPUT_CONTEXT~ to search')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:searchDrawer', 2)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drawerThree.x, bank.drawerThree.y, bank.drawerThree.z) < 0.5 and (bank.startOne.picked or bank.startTwo.picked) and not bank.drawerThree.searched then--Cash Drawer 3
			DisplayHelpText('Press ~INPUT_CONTEXT~ to search')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:searchDrawer', 3)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.bankersDesk.x, bank.bankersDesk.y, bank.bankersDesk.z) < 0.5 and (bank.startOne.picked or bank.startTwo.picked) and not bank.bankersDesk.searched then --Bankers desk search
			DisplayHelpText('Press ~INPUT_CONTEXT~ to search')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:searchDrawer', 4)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.hack2.x, bank.hack2.y, bank.hack2.z) < 0.75 and not bank.hack2.hacked then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to hack')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startHack', 4)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.lockpick1.x, bank.lockpick1.y, bank.lockpick1.z) < 0.75 and not bank.lockpick1.picked then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startLockpick', 5)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.lockpick2.x, bank.lockpick2.y, bank.lockpick2.z) < 0.75 and not bank.lockpick2.picked then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startLockpick', 6)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drill1.x, bank.drill1.y, bank.drill1.z) < 0.75 and not bank.drill1.drilling and not bank.drill1.drilled then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startThermite', 1)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drill2.x, bank.drill2.y, bank.drill2.z) < 0.75 and not bank.drill2.drilling and not bank.drill2.drilled then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startThermite', 2)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drill3.x, bank.drill3.y, bank.drill3.z) < 0.75 and not bank.drill3.drilling and not bank.drill3.drilled then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startThermite', 3)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drill4.x, bank.drill4.y, bank.drill4.z) < 0.75 and not bank.drill4.drilling and not bank.drill4.drilled then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startThermite', 4)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.drill5.x, bank.drill5.y, bank.drill5.z) < 0.75 and not bank.drill5.drilling and not bank.drill5.drilled then
			DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite')
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_swedbank:startThermite', 5)
			end
		elseif Vdist(pos.x, pos.y, pos.z, bank.exit.x, bank.exit.y, bank.exit.z) < 0.75 then
			TriggerServerEvent('yp_swedbank:leaveStore')
		elseif Vdist(pos.x, pos.y, pos.z, bank.exitSide.x, bank.exitSide.y, bank.exitSide.z) < 0.75 then
			TriggerServerEvent('yp_swedbank:leaveStore')
		end
		Citizen.Wait(0)
	end
end)