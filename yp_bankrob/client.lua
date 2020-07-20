--ESX INIT
local ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
 
local buttonsPick = {{char = 'Up', value = 172}, {char = 'Down', value = 173}, {char = 'Left', value = 174}, {char = 'Right', value = 175}}
local buttonsHax = {{char = 'Q', value = 52}, {char = 'W', value = 77}, {char = 'E', value = 51}, {char = 'Z', value = 48}, {char = 'X', value = 105}, {char = 'C', value = 26}}
local buttonsThermite = {{char = 'Q', value = 52}, {char = 'W', value = 77}, {char = 'E', value = 51}, {char = 'A', value = 34}, {char = 'S', value = 31}, {char = 'D', value = 30}}

local result = nil
local updatedDoors = false
local listening = false
local pressed = false
local blip = nil
local isRobber = false
local isRobbing = false

--Functions
function listenForPress(key)
  Citizen.CreateThread(function()
	while listening do
	  if IsControlJustPressed(1, key) or IsDisabledControlJustPressed(0, key) then
		pressed = true
	  end
	  Citizen.Wait(0)
	end
  end)
end

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isRobbing then
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D
			DisableControlAction(0, 51, true) -- E
			DisableControlAction(0, 26, true) -- C

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 167, true) -- Job
      		DisableControlAction(0, 137, true) -- Job


			DisableControlAction(0, 73, true) -- Disable clearing animation

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
	end
end)



function hack()
	exports['mythic_notify']:DoHudText('inform', 'Hacking starting')
  	local failed = 0
  	local correct = 0
  	Citizen.CreateThread(function()--Main Thread for the hack
		isRobbing = true
		Citizen.Wait(2500)
		while failed < 3  and correct < 10 do 
	  	local letter = math.random(1,#buttonsHax)
	  	exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsHax[letter].char)
	  	listening = true
	  	listenForPress(buttonsHax[letter].value)
		Citizen.Wait(800) --Timer to press Key
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
		  	exports['mythic_notify']:DoShortHudText('success', 'Checking for footprints')
		elseif correct == 9 then
		  	exports['mythic_notify']:DoShortHudText('success', 'Clearing footprints')
		else
		  	exports['mythic_notify']:DoShortHudText('success', 'Access Granted')
		  	isRobbing = false
		end
	  else
		failed = failed + 1
		exports['mythic_notify']:DoShortHudText('error', 'Failed to make progress')
		isRobbing = false
	  end
	  pressed = false
	  Citizen.Wait(2500)
	end
	result = (not (failed == 3))
  end)
end

function lockpick()
	exports['mythic_notify']:DoHudText('inform', 'Lockpicking starting')
	local failed = 0
	local correct = 0

	Citizen.CreateThread(function()--Main Thread for the lockpicking
		isRobbing = true
	Citizen.Wait(2500)
		while failed < 1  and correct < 5 do 
			local letter = math.random(1,#buttonsPick)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsPick[letter].char)
			listening = true
			listenForPress(buttonsPick[letter].value)
			Citizen.Wait(800) --Timer to press Key
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
					isRobbing = false
				end
			else
				exports['mythic_notify']:DoShortHudText('error', 'Your Lockpick broke!')
				failed = failed + 1
				isRobbing = false
			end
			pressed = false
			Citizen.Wait(2500)
		end
		result = (not (failed == 1))
	end)
end

function thermite()
	exports['mythic_notify']:DoHudText('inform', 'Prepping Thermite')
	local failed = 0
	local correct = 0
	Citizen.CreateThread(function()--Main Thread for the thermite
		isRobbing = true
	Citizen.Wait(2500)
		while failed < 1  and correct < 5 do 
			local letter = math.random(1,#buttonsThermite)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttonsThermite[letter].char)
			listening = true
			listenForPress(buttonsThermite[letter].value)
			Citizen.Wait(800) --Timer to press Key
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
					isRobbing = false
				end
			else
				exports['mythic_notify']:DoShortHudText('error', 'Thermite Prep Unsuccessful...')
				failed = failed + 1
				isRobbing = false
			end
			pressed = false
			Citizen.Wait(2500)
		end
		result = (not (failed == 1))
	end)
end

function openDoor(bankInd, doorNum)
	if doorNum == 0 then --Front Counter door locked/Unlock
		local door = GetClosestObjectOfType(Banks[bankInd].counterDoor.x, Banks[bankInd].counterDoor.y, Banks[bankInd].counterDoor.z, 3.0, Banks[bankInd].doorModel)
		FreezeEntityPosition(door, false)
		Citizen.CreateThread(function()
			local x = 0

			while x < 200 do
				SetEntityRotation(door, 0,0, GetEntityRotation(door)['z'] - 0.5)
				x = x + 1
				Citizen.Wait(0)
			end
			FreezeEntityPosition(door,true)

		end)

	elseif doorNum == 1 then -- Vault Door
		local door = GetClosestObjectOfType(Banks[bankInd].hacks[1].x, Banks[bankInd].hacks[1].y, Banks[bankInd].hacks[1].z, 3.0, Banks[bankInd].vaultModel)
		FreezeEntityPosition(door, false)
		Citizen.CreateThread(function()
			local x = 0

			while x < 400 do
				SetEntityRotation(door, 0,0, GetEntityRotation(door)['z'] + Banks[bankInd].motion)
				x = x + 1
				Citizen.Wait(0)
			end
			FreezeEntityPosition(door,true)

		end)
	else --Gate to vault
		local door = GetClosestObjectOfType(Banks[bankInd].hacks[2].x, Banks[bankInd].hacks[2].y, Banks[bankInd].hacks[2].z, 3.0, Banks[bankInd].gateModel)
		FreezeEntityPosition(door, false)
	end
end

function closeDoor(bankInd, doorNum)
	local bank = Banks[bankInd]
	if doorNum == 0 then --Front Counter door locked/Unlock
		local door = GetClosestObjectOfType(bank.counterDoor.x, bank.counterDoor.y, bank.counterDoor.z, 3.0, bank.doorModel)
		FreezeEntityPosition(door, false)
		SetEntityRotation(door, 0, 0, bank.doorRotation)
		FreezeEntityPosition(door,true)

	elseif doorNum == 1 then -- Vault Door
		local door = GetClosestObjectOfType(bank.hacks[1].x, bank.hacks[1].y, bank.hacks[1].z, 3.0, bank.vaultModel)
		FreezeEntityPosition(door, false)
		SetEntityRotation(door, 0, 0, bank.vaultRotation)
		FreezeEntityPosition(door,true)
	else --Gate to vault
		local door = GetClosestObjectOfType(bank.hacks[2].x, bank.hacks[2].y, bank.hacks[2].z, 3.0, bank.gateModel)
		FreezeEntityPosition(door, false)
		SetEntityRotation(door, 0, 0, bank.gateRotation)
		FreezeEntityPosition(door,true)
	end
end

function drill()
	local playerPed = GetPlayerPed(-1)
	Citizen.CreateThread(function()
		local drillTime = math.random(20,25)
		TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
		exports['progressBars']:startUI(drillTime * 1000, "Opening Box")
		Citizen.Wait(drillTime * 1000)
		ClearPedTasksImmediately(playerPed)
		TriggerServerEvent('yp_bankrob:finishDrilling')
	end)
end

--Register Events
RegisterNetEvent('yp_bankrob:hack')
AddEventHandler('yp_bankrob:hack', function(bankInd, hackInd)
	exports['yp_base']:addStress(15000)
	Citizen.CreateThread(function()
		hack()

		while result == nil do
			Citizen.Wait(0)
		end

		if result then
			--Hack success
			TriggerServerEvent('yp_bankrob:updateDoorStatus', bankInd, hackInd)
		else
			--hack failed
			exports['mythic_notify']:DoHudText('error', 'Hacking failed...')
			TriggerServerEvent('yp_bankrob:consumeDrive')
			TriggerServerEvent('yp_bankrob:unHack', bankInd, hackInd)
		end

		result = nil
	end)
end)

RegisterNetEvent('yp_bankrob:lockpick')
AddEventHandler('yp_bankrob:lockpick', function(bankInd)
	exports['yp_base']:addStress(15000)
	Citizen.CreateThread(function()
		lockpick()

		while result == nil do
			Citizen.Wait(0)
		end

		if result then
			--Pick success
			TriggerServerEvent('yp_bankrob:updateDoorStatus', bankInd, 0)
		else
			--pick failed
			exports['mythic_notify']:DoHudText('error', 'Lockpicking failed...')
			TriggerServerEvent('yp_bankrob:consumePick')
			TriggerServerEvent('yp_bankrob:unPick', bankInd)
		end

		result = nil
	end)
end)

RegisterNetEvent('yp_bankrob:thermite')
AddEventHandler('yp_bankrob:thermite', function(bankInd, drillNum)
	exports['yp_base']:addStress(15000)
	Citizen.CreateThread(function()
		thermite()

		while result == nil do
			Citizen.Wait(0)
		end

		if result then
			drill()
		else
			--thermite failed
			exports['mythic_notify']:DoHudText('error', 'Thermite Prep failed...')
			TriggerServerEvent('yp_bankrob:consumeThermite')
			TriggerServerEvent('yp_bankrob:unDrill', bankInd, drillNum)
		end

		result = nil
	end)
end)

RegisterNetEvent('yp_bankrob:openDoor')
AddEventHandler('yp_bankrob:openDoor', function(bank, doorNum)
	openDoor(bank, doorNum)
end)

RegisterNetEvent('yp_bankrob:closeDoor')
AddEventHandler('yp_bankrob:closeDoor', function(bank, doorNum)
	closeDoor(bank, doorNum)
end)

RegisterNetEvent('yp_bankrob:createAlarmBlip')
AddEventHandler('yp_bankrob:createAlarmBlip', function(bank)
	blip = AddBlipForCoord(Banks[bank].counterDoor.x, Banks[bank].counterDoor.y, Banks[bank].counterDoor.y)
    SetBlipSprite(blip , 161)
    SetBlipScale(blip , 2.0)
    SetBlipColour(blip, 3)
    PulseBlip(blip)
end)

RegisterNetEvent('yp_bankrob:removeBlip')
AddEventHandler('yp_bankrob:removeBlip', function()
	RemoveBlip(blip)
end)

RegisterNetEvent('yp_bankrob:becomeRobber')
AddEventHandler('yp_bankrob:becomeRobber', function()
	isRobber = true
end)

RegisterNetEvent('yp_bankrob:robRegister')
AddEventHandler('yp_bankrob:robRegister', function()
	exports['yp_base']:addStress(15000)
	Citizen.CreateThread(function()
		local searchTime = math.random(15,20)
		local searched = 0

		exports['progressBars']:startUI(searchTime * 1000, "Grabbing cash")
		exports['yp_base']:FreezePlayer()
		local playerPed = GetPlayerPed(-1)
		loadAnimDict("anim@heists@ornate_bank@grab_cash") 
		TaskPlayAnim(playerPed, "anim@heists@ornate_bank@grab_cash", "grab", 8.0, 1.0, -1, 2, 0, 0, 0, 0)

		while searched ~= searchTime do
			searched = searched + 1
			Citizen.Wait(1000)
		end

		TriggerServerEvent('yp_bankrob:payoutRegister')
		ClearPedTasksImmediately(playerPed)
		exports['yp_base']:UnFreezePlayer()
	end)
end)

--Main Thread 
Citizen.CreateThread(function()
	local currentBank = -1
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		for i, v in ipairs(Banks) do 
			if Vdist(pos.x, pos.y, pos.z, v.exit.x, v.exit.y, v.exit.z) < 15 then --If close enough to the bank
				currentBank = i

				if not updatedDoors then--Have you rendered changes to the doors
					updatedDoors = true
					TriggerServerEvent('yp_bankrob:updateDoors', i)--Render door changes
				end

				for i2, v2 in ipairs(v.hacks) do
					if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 0.5 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to hack')
						if not isRobbing and IsControlJustPressed(0, 51) then
							TriggerServerEvent('yp_bankrob:startHack', i, i2, GetClockHours())
						end
					end
				end

				if Vdist(pos.x, pos.y, pos.z, v.counterDoor.x, v.counterDoor.y, v.counterDoor.z) < 1 then
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick the door')
					if IsControlJustPressed(0,51) then
						TriggerServerEvent('yp_bankrob:startPick', i, GetClockHours())
					end
				end

				for i2, v2 in ipairs(v.registers) do
					if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 0.5 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to rob the counter')
						if IsControlJustPressed(0,51) then
							TriggerServerEvent('yp_bankrob:startRegister', i, i2)
						end
					end
				end

				for i2, v2 in ipairs(v.drills) do
					if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 1 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to use thermite on the boxes')
						if not isRobbing and IsControlJustPressed(0, 51) then
							TriggerServerEvent('yp_bankrob:startThermite', i, i2)
						end
					end
				end

				if Vdist(pos.x, pos.y, pos.z, v.exit.x, v.exit.y, v.exit.z) < 1 then
					if isRobber then
						TriggerServerEvent('yp_bankrob:endRob', i)
					end
				end

			else
				if updatedDoors and i == currentBank then --The player is too far to render the doors
					updatedDoors = false
					currentBank = -1
				end
			end
		end

		Citizen.Wait(0)
	end
end)