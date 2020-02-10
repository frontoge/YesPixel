--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--[[Important coords
--Weed Farm: x = 1065.1511, y = -3183.4865, z = -39.1635
--Cocaine Lockup: x = 1088.7777, y = -3188.9726, z = -38.9934
]]--

--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local cooking = false
local blip = nil


function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

--[[
	Gives the player armor from a high until the timer is up.
	amount = The percentage of armor the player recieves from the high
	time = The time in minutes of the high
]]--
function getArmorFromHigh(amount, time)
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		AddArmourToPed(playerPed, amount)
		Citizen.Wait(time * 1000)
		if GetPedArmour(playerPed) - amount >= 0 then
			SetPedArmour(playerPed, GetPedArmour(playerPed) - amount)
		else
			SetPedArmour(playerPed, 0)
		end
	end)
end

RegisterNetEvent('yp_drugs:actions:useCocaine')
AddEventHandler('yp_drugs:actions:useCocaine', function()
	--Increase Speed 
	local playerPed = GetPlayerPed(-1)
	Citizen.CreateThread(function()
		SetPedMoveRateOverride(playerPed, 2.0)
		SetRunSprintMultiplierForPlayer(PlayerId(), SpeedMultCoke)
		AnimpostfxPlay('DrugsDrivingOut', 0, true)
		exports['yp_base']:addStress(75000)
		local x = 0
		while x < 80 do
			Citizen.Wait(500)
			RestorePlayerStamina(PlayerId(), 1.0)
			x = x + 1
		end
		SetPedMoveRateOverride(playerPed, 1.0)
		SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
		AnimpostfxStop('DrugsDrivingOut')
    end)
    
end)

RegisterNetEvent('yp_drugs:actions:useMeth')
AddEventHandler('yp_drugs:actions:useMeth', function()
	Citizen.CreateThread(function()
		print('meth')
		AnimpostfxPlay('DrugsDrivingOut', 0, 1.0)
		exports['yp_base']:addStress(100000)
		getArmorFromHigh(ArmorBonusMeth, MethArmorTimer)
		Citizen.Wait(1000 * 180)
		AnimpostfxStop('DrugsDrivingOut')
    end)
end)

RegisterNetEvent('yp_drugs:actions:useJoint')
AddEventHandler('yp_drugs:actions:useJoint', function()
	loadAnimDict('timetable@gardener@smoking_joint')
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local timer = 0
		local prop = CreateObject(GetHashKey('prop_sh_joint_01'), x, y, z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(playerPed, 0xFA10)

		AttachEntityToEntity(prop, playerPed, boneIndex, 0.03, 0.0, 0.02, 120.0, 190.0, 50.0, true, false, false, true, 1, true)
		TaskPlayAnim( playerPed, "timetable@gardener@smoking_joint", "smoke_idle", 8.0, 1.0, -1, 50, 0, 0, 0, 0 )
		exports['yp_base']:FreezePlayer()
		while timer < 15 do
			Citizen.Wait(1000)
			timer = timer + 1
		end

		exports['yp_base']:removeStress(150000)
		getArmorFromHigh(ArmorBonusWeed, WeedArmorTimer)

		ClearPedSecondaryTask(playerPed)
		DeleteObject(prop)
		exports['yp_base']:UnFreezePlayer()

 	end)
end)

RegisterNetEvent('yp_drugs:actions:useBlunt')
AddEventHandler('yp_drugs:actions:useBlunt', function(source)
	loadAnimDict('timetable@gardener@smoking_joint')
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local timer = 0
		local prop = CreateObject(GetHashKey('prop_sh_joint_01'), x, y, z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(playerPed, 0xFA10)

		AttachEntityToEntity(prop, playerPed, boneIndex, 0.03, 0.0, 0.02, 120.0, 190.0, 50.0, true, false, false, true, 1, true)
		TaskPlayAnim(playerPed, "timetable@gardener@smoking_joint", "smoke_idle", 8.0, 1.0, -1, 50, 0, 0, 0, 0)

		while timer < 15 do
			Citizen.Wait(1000)
			timer = timer + 1
		end

		exports['yp_base']:removeStress(300000)
		getArmorFromHigh(ArmorBonusWeed * 2, WeedArmorTimer)

		ClearPedSecondaryTask(playerPed)
		DeleteObject(prop)

 	end)
end)

RegisterNetEvent('yp_drugs:actions:useCigarette')
AddEventHandler('yp_drugs:actions:useCigarette', function()
	loadAnimDict('amb@world_human_smoking@male@male_a@idle_a')
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local timer = 0

		TaskPlayAnim(playerPed, "amb@world_human_smoking@male@male_a@idle_a", "WOLRD_HUMAN_SMOKING", 8.0, 1.0, -1, 50, 0, 0, 0, 0)

		while timer < 15 do
			Citizen.Wait(1000)
			timer = timer + 1
		end

		exports['yp_base']:removeStress(200000)

		ClearPedSecondaryTask(playerPed)

 	end)
end)

RegisterNetEvent('yp_drugs:actions:useHeroin')
AddEventHandler('yp_drugs:actions:useHeroin', function()
	exports['yp_base']:removeStress(250000)
	TriggerEvent("esx_status:add", 'drunk', 200000)
end)

RegisterNetEvent('yp_drugs:actions:useXanax')
AddEventHandler('yp_drugs:actions:useXanax', function()
	Citizen.CreateThread(function()
		SetTimecycleModifier("spectator5")
    	SetPedMotionBlur(playerPed, true)
    	exports['yp_base']:removeStress(500000)
    	Citizen.Wait(300 * 1000)
    	ClearTimecycleModifier()
    	SetPedMotionBlur(playerPed, false)
    end)
end)

RegisterNetEvent('yp_drugs:actions:useVicodin')
AddEventHandler('yp_drugs:actions:useVicodin', function()
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		getArmorFromHigh(ArmorBonusVicodin, VicodinArmorTimer)
		SetPedMoveRateOverride(playerPed, 0.5)
		SetRunSprintMultiplierForPlayer(PlayerId(), SpeedMultVicodin)
		exports['yp_base']:removeStress(300000)
		Citizen.Wait(60 * 1000)
		SetPedMoveRateOverride(playerPed, 1.0)
		SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end)
end)

RegisterNetEvent('yp_drugs:actions:useLSD')
AddEventHandler('yp_drugs:actions:useLSD', function()
	local playerPed = GetPlayerPed(-1)
	Citizen.CreateThread(function()
		exports['yp_base']:addStress(200000)
		AnimpostfxPlay('RaceTurbo', 0, true)
		SetTimecycleModifier("spectator5")
    	SetPedMotionBlur(playerPed, true)
		Citizen.Wait(1000 * LSDTimer)
		ClearTimecycleModifier()
    	SetPedMotionBlur(playerPed, false)
		AnimpostfxStopAll()
		DoScreenFadeOut(2000)
		Citizen.Wait(4000)
		local x, y, z = table.unpack(GetEntityCoords(playerPed))
		local x = x + math.random(0, 250)
		local y = y + math.random(0, 250)
		z = 0.0
		if math.random(1, 2) == 2 then
			x = x * -1
		else
			y = y * -1
		end
		SetEntityCoords(GetPlayerPed(-1), tonumber(x), tonumber(y), tonumber(z) , 1, 0, 0, 1)
		DoScreenFadeIn(2000)
    end)
end)

RegisterNetEvent('yp_drugs:actions:rollWeed')
AddEventHandler('yp_drugs:actions:rollWeed', function(item)
	Citizen.CreateThread(function()
		local timer = 0
		local x = 0

		if item == 'blunt' then
			timer = 12
		else
			timer = 7
		end

		exports['progressBars']:startUI(timer * 1000, "Rolling Weed")
		
		while x < timer do
			Citizen.Wait(1000)
			x = x + 1
		end

		TriggerServerEvent('yp_base:addItem', item, 1)
	end)
end)

RegisterNetEvent('yp_drugs:crafting:makeMeth')
AddEventHandler('yp_drugs:crafting:makeMeth', function()
	cooking = true
	local count = 0
	exports['mythic_notify']:DoHudText('inform', 'Meth cooking started')
	exports['progressBars']:startUI(10000, 'Mixing ingredients')
	while count < 10 do
		count = count + 1
		Citizen.Wait(1000)
	end
	count = 0
	timer = math.random(15, 25)
	Citizen.Wait(500)
	exports['progressBars']:startUI(timer * 1000, 'Cooking meth')
	while count < timer do
		count = count + 1
		Citizen.Wait(1000)
	end

	local payout = math.random(5, 7)
	TriggerServerEvent('yp_base:addItem', 'meth', payout)
	exports['mythic_notify']:DoHudText("success", "You cooked " .. payout .. " meth")
	cooking = false
end)

RegisterNetEvent('yp_drugs:crafting:makeCoke')
AddEventHandler('yp_drugs:crafting:makeCoke', function()
	cooking = true
	local count = 0
	exports['mythic_notify']:DoHudText('inform', 'Started making cocaine')
	exports['progressBars']:startUI(10000, 'Mixing ingredients')
	while count < 10 do
		count = count + 1
		Citizen.Wait(1000)
	end
	count = 0
	timer = math.random(15, 25)
	Citizen.Wait(500)
	exports['progressBars']:startUI(timer * 1000, 'Packaging Cocaine')
	while count < timer do
		count = count + 1
		Citizen.Wait(1000)
	end

	local payout = math.random(3, 5)
	TriggerServerEvent('yp_base:addItem', 'cocaine', payout)
	exports['mythic_notify']:DoHudText("success", "You made " .. payout .. ' cocaine')
	cooking = false
end)

RegisterNetEvent('yp_drugs:pickCoca')
AddEventHandler('yp_drugs:pickCoca', function()
	Citizen.CreateThread(function()
		local payout = math.random(CocaDropMin, CocaDropMax)
		local playerPed = GetPlayerPed(-1)
		exports['progressBars']:startUI(10000, "Picking...")
		TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
		Citizen.Wait(10000)
		ClearPedTasksImmediately(playerPed)
		TriggerServerEvent('yp_base:addItem', 'cocaleaf', payout)
	end)
end)

Citizen.CreateThread(function() -- Create Blip for store
	blip = AddBlipForCoord(-1172.5959, -1572.2142, 4.6636)
	SetBlipSprite(blip, 140)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Dispensary")
	EndTextCommandSetBlipName(blip)
end)

--Main Thread
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)
		for i, v in ipairs(Dispense) do
			if Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 1 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to shop')
				if IsControlJustPressed(0,51) then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dispensary_menu', {
						title = 'Dispensary',
						align = 'bottom-right',
						elements = 
						{
							{label = 'Weed', value = 'weed'},
							{label = 'Rolling Papers', value = 'rollingpapers'},
							{label = 'Cigarillos', value = 'cigarillo'}
						}
					},
					function(data, menu)
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'amount_menu', {title = 'Amount:'},
							function(data2, menu2)
								local input = tonumber(data2.value)
								if (data.current.value == 'weed' and input <= 20) or data.current.value ~= 'weed' then
									menu2.close()
									ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cash_card', {
										title = 'Payment Method',
										align = 'bottom-right',
										elements = {
											{label = 'Card', value = 'card'},
											{label = 'Cash', value = 'cash'}
										}
									},
									function(data3, menu3)
										menu3.close()
										local cost = Prices[data.current.value] * input
										local card = false
										if data3.current.value == 'card' then
											card = true
										end

										TriggerServerEvent('yp_drugs:buyFromDispensary', data.current.value, input, cost, card)
									end,
									function(data3, menu3)
										menu3.close()
									end)
								elseif data.current.value == 'weed' then
									exports['mythic_notify']:DoHudText('error', 'You cannot purcase more than 20g of weed.')
								end
							end,
							function(data2, menu2)
								menu2.close()
							end)
					end,
					function(data, menu)
						menu.close()
					end)
				end
			end
		end

		for i, v in ipairs(CocaFarm) do 
			if Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 2 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to tend to the crops')
				if IsControlJustPressed(0, 51) then
					TriggerServerEvent('yp_drugs:farmCoca', i)
				end
			end
		end

		--Locations
		if Vdist(pos.x, pos.y, pos.z, 1390.5275, 3605.5852, 39.7759) < 3 and not cooking then --Meth Cooking
			exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to cook meth')
			if IsControlJustPressed(0, 51) then
				TriggerServerEvent('yp_drugs:cookMeth')
			end
		elseif Vdist(pos.x, pos.y, pos.z, 1093.9084, -3195.7758, -38.1202) < 3 and not cooking then
			exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to make cocaine')
			if IsControlJustPressed(0, 51) then
				TriggerServerEvent('yp_drugs:makeCoke')
			end
		--TP to coke room
		elseif Vdist(pos.x, pos.y, pos.z, 1088.7777, -3188.9726, -38.9934) < 20 then --Exit cocaine Lockup
			DrawMarker(1, 1088.7777, -3188.9726, -39.9934, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			if Vdist(pos.x, pos.y, pos.z, 1088.7777, -3188.9726, -38.9934) < 1 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to leave')
				if IsControlJustPressed(0, 51) then
					SetEntityCoords(playerPed, 387.6297, 3585.9726, 33.2922, 1, 0, 0, 1)
				end
			end
		elseif Vdist(pos.x, pos.y, pos.z, 387.6297, 3585.9726, 33.2922) < 20 then --Entrance cocaine lockup
			DrawMarker(1, 387.6297, 3585.9726, 32.2922, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			if Vdist(pos.x, pos.y, pos.z, 387.6297, 3585.9726, 33.2922) < 1 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to go inside')
				if IsControlJustPressed(0, 51) then
					SetEntityCoords(playerPed, 1088.7777, -3188.9726, -38.9934, 1, 0, 0, 1)
				end
			end
		end

		Citizen.Wait(0)
	end
end)
