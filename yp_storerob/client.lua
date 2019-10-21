--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local blips = {}
local buttons = {{char = 'Up', value = 172}, {char = 'Down', value = 173}, {char = 'Left', value = 174}, {char = 'Right', value = 175}}

--ESX init
ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

--Fucntions
function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
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

function isRobber(store, id)
	for i, v in ipairs(Stores[store].robbers) do
		if id == v then
			return true
		end
	end
	return false
end

--Events
RegisterNetEvent('yp_storerob:startRobbery')
AddEventHandler('yp_storerob:startRobbery', function(store)
	Stores[store].beingRobbed = true
end)

RegisterNetEvent('yp_storerob:addBlip')
AddEventHandler('yp_storerob:addBlip', function(pos, store)
	blips[store] = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blips[store] , 161)
    SetBlipScale(blips[store] , 2.0)
    SetBlipColour(blips[store], 3)
    PulseBlip(blips[store])
end)

RegisterNetEvent('yp_storerob:robRegister')
AddEventHandler('yp_storerob:robRegister', function()
	Citizen.CreateThread(function()
		local searchTime = math.random(15,20)
		local searched = 0

		exports['progressBars']:startUI(searchTime * 1000, "Grabbing cash")
		exports['yp_base']:FreezePlayer()
		local playerPed = GetPlayerPed(-1)
		loadAnimDict("anim@heists@ornate_bank@grab_cash") 
		TaskPlayAnim( playerPed, "anim@heists@ornate_bank@grab_cash", "grab", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

		while searched ~= searchTime do
			searched = searched + 1
			Citizen.Wait(1000)
		end

		TriggerServerEvent('yp_storerob:payoutRegister')
		ClearPedTasksImmediately(playerPed)
		exports['yp_base']:UnFreezePlayer()
	end)

end)

RegisterNetEvent('yp_storerob:toggleRegister')
AddEventHandler('yp_storerob:toggleRegister', function(store, register)
	Stores[store].registers[register].robbed = true
end)

RegisterNetEvent('yp_storerob:addRobber')
AddEventHandler('yp_storerob:addRobber', function(id, store)
	if not isRobber(store, id) then
		table.insert(Stores[store].robbers, id)
	end
end)

RegisterNetEvent('yp_storerob:disableSafe')
AddEventHandler('yp_storerob:disableSafe', function(store)
	Stores[store].safe.robbed = true
end)

RegisterNetEvent('yp_storerob:enableSafe')
AddEventHandler('yp_storerob:enableSafe', function(store)
	Stores[store].safe.robbed = false
end)

RegisterNetEvent('yp_storerob:lockpickSafe')
AddEventHandler('yp_storerob:lockpickSafe', function(store)
	exports['yp_base']:FreezePlayer()
	local success = false
	if not Stores[store].beingRobbed then
		TriggerServerEvent('yp_storerob:alertPolice', v, i)
	end

	exports['mythic_notify']:DoHudText('inform', 'Lockpicking starting')
	local failed = 0
	local correct = 0
	Citizen.CreateThread(function()--Main Thread for the lockpicking
	Citizen.Wait(2500)
		while failed < 1  and correct < 5 do 
			local letter = math.random(1,4)
			exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttons[letter].char)
			listening = true
			listenForPress(buttons[letter].value)
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
			TriggerServerEvent('yp_storerob:failedSafe', store)
		else
			Citizen.CreateThread(function()
				local searchTime = math.random(20,25)
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
				TriggerServerEvent('yp_storerob:payoutSafe')
				ClearPedTasksImmediately(playerPed)
				exports['yp_base']:UnFreezePlayer()
			end)
		end
	end)
end)

RegisterNetEvent('yp_storerob:endBlip')
AddEventHandler('yp_storerob:endBlip', function(store)
	RemoveBlip(blips[store])
end)

RegisterNetEvent('yp_storerob:endRob')
AddEventHandler('yp_storerob:endRob', function(store)
	Stores[store].robbers = {}
	Stores[store].beingRobbed = false
end)

--Main Thread
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		for i, v in ipairs(Stores) do--For Each Store
			if Vdist(pos.x, pos.y, pos.z, v.exits[1].x, v.exits[1].y, v.exits[1].z) < 40 then --If you are near the store then check for the following

				for i2, v2 in ipairs(v.registers) do --For each register in the store
					if not v2.robbed then --Is the register robbed?
						if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 1 then --Are you at the register
							exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to rob the register')
							if IsControlJustPressed(0,51) then 
								if not v.onCooldown then --Is the store not on cooldown
									if not v.beingRobbed then --Is the store not already beingRobbed?
										TriggerServerEvent('yp_storerob:alertPolice', v, i)
									end
									TriggerEvent('yp_storerob:robRegister')
									TriggerServerEvent('yp_storerob:updateRegisterState', i, i2)
									TriggerServerEvent('yp_storerob:updateRobbery', i)
								else
									exports['mythic_notify']:DoHudText('error', 'This store has already been robbed, come back in ' .. v.cooldown .. 's')
								end
							end
						end
					end
				end
				
				if v.safe ~= nil then
					if not v.safe.robbed then--Safe Portion
						if Vdist(pos.x, pos.y, pos.z, v.safe.x, v.safe.y, v.safe.z) < 1 then
							exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to lockpick the safe')
							if IsControlJustPressed(0,51) then
								if not v.onCooldown then
									TriggerServerEvent('yp_storerob:startSafeRob', i, v)
								else
									exports['mythic_notify']:DoHudText('error', 'This store has already been robbed, come back in ' .. v.cooldown .. 's')
								end
							end
						end
					end
				end

				if v.beingRobbed then
					for i2, v2 in ipairs(v.exits) do
						if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 1 then
							TriggerServerEvent('yp_storerob:endRob', i, v)
							Stores[i].beingRobbed = false
						end
					end
				end

			end
		end

		Citizen.Wait(0)
	end
end)
