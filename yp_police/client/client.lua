--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local playerReady = true
local isPolice = true
local invData = {}
local pdBlip = nil


--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--Draw Blip
Citizen.CreateThread(function()
	pdBlip = AddBlipForCoord(446.4296, -985.3162, 30.6893)
	SetBlipSprite(pdBlip, 60)
	SetBlipDisplay(pdBlip, 4)
	SetBlipScale(pdBlip, 1.0)
	SetBlipColour(pdBlip, 3)
	SetBlipAsShortRange(pdBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Police Station")
	EndTextCommandSetBlipName(pdBlip)
end)
--End Blip drawing

--Functions
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function openJobMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_menu', {
		title = 'Police Menu',
		align = 'bottom-right',
		elements = {
			{label = 'Player Interactions', value = 'players'},
			{label = 'Vehicle Interactions', value = 'vehicles'},
			{label = 'Object Spawner', value = 'object'},
			{label = 'Open CAD', value = 'cad'}}
	},
	function(data, menu)
		local action = data.current.value
		if action == 'players' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'players_menu', {
				title = 'Player Interactions',
				align = 'bottom-right',
				elements = {
					{label = 'Cuff', value = 'cuff'},
					{label = 'Uncuff', value = 'uncuff'},
					{label = 'View ID', value = 'viewid'},
					{label = 'Search', value = 'search'},
					{label = 'Escort', value = 'escort'},
					{label = 'Put in Vehicle', value = 'putveh'},
					{label = 'Pull From Vehicle', value = 'pullveh'},
					{label = 'Fine', value = 'fine'},
					{label = 'Jail Player', value = 'jail'}}
			},
			function(data2, menu2)
				local action2 = data2.current.value
				if action2 == 'cuff' then

					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if closestPlayer ~= -1 and distance < 3.0 then
						TriggerServerEvent('yp_police:cuffPlayer', GetPlayerServerId(closestPlayer))
					end

				elseif action2 == 'uncuff' then

					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if closestPlayer ~= -1 and distance < 3.0 then
						TriggerServerEvent('yp_police:uncuffPlayer', GetPlayerServerId(closestPlayer))
					end

				elseif action2 == 'viewid' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if closestPlayer ~= -1 and distance < 3.0 then
						TriggerServerEvent('yp_police:getPlayerInfo', GetPlayerServerId(closestPlayer))
					end
				elseif action2 == 'search' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
		            if closestPlayer ~= -1 and distance <= 3 then
		                if IsPedCuffed(GetPlayerPed(closestPlayer)) then
		                    TriggerServerEvent('yp_userinteraction:getPlayerInventory', closestPlayer)
		                else
		                    exports['mythic_notify']:DoHudText('error', 'Player not Cuffed!')
		                end
		            else
		             	exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
		            end
				elseif action2 == 'escort' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if closestPlayer ~= -1 and distance < 3.0 then
						TriggerServerEvent('yp_police:escort', GetPlayerServerId(closestPlayer))
					end
				elseif action2 == 'putveh' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
		            if closestPlayer ~= -1 and distance <= 2 then
		            	TriggerServerEvent('yp_userinteraction:putInVehicle', GetPlayerServerId(closestPlayer))
		            end
				elseif action2 == 'pullveh' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
		            if closestPlayer ~= -1 and distance <= 2 then
		            	TriggerServerEvent('yp_userinteraction:pullOutVehicle', GetPlayerServerId(closestPlayer))
		            end
				elseif action2 == 'fine' then
					--Issue a player a fine
				else
					--Jailmenu
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif action == 'vehicles' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicles_menu', {
				title = 'Vehicle Interactions',
				align = 'bottom-right',
				elements = {
					{label = 'Get Registration', value = 'registration'},
					{label = 'Impound Vehicle', value = 'impound'},
					{label = 'Search Trunk', value = 'search_trunk'},
					{label = 'Search Glovebox', value = 'search_glovebox'},
					{label = 'Lockpick', value = 'lockpick'}
				}},
			function(data2, menu2)
				local action2 = data2.current.value
				if action2 == 'registration' then
					--Registration Code

				elseif action2 == 'impound' then
					local vehicle = ESX.Game.GetVehicleInDirection()
					if DoesEntityExist(vehicle) then
						Citizen.CreateThread(function()
							exports['progressBars']:startUI(10000, "Impounding...")
							TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDNER_PLANT', 0, true)
					        Citizen.Wait(10000)
					        ClearPedTasksImmediately(playerPed)
					        ESX.Game.DeleteVehicle(vehicle)
						end)
						
					else
						exports['mythic_notify']:DoHudText('error', 'There is no vehicle nearby')
					end
				elseif action2 == 'search_trunk' then

				elseif action2 == 'search_glovebox' then

				else
					TriggerEvent('yp_userinteraction:lockpickvehicle')

				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif action == 'object' then
			--Start Object spawner menu
		else
			--Start CAD
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

function armoryMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_menu', {
		title = 'Armory',
		align = 'bottom-right',
		elements = {
			{label = 'Weapons', value = 'weapons'},
			{label = 'Equipment', value = 'equipment'}
		}},
		function(data, menu)
			local elements = nil
			if data.current.value == 'weapons' then
				elements = weapons
			else
				elements = equip
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_weapons', {
				title = 'Weapons',
				align = 'bottom-right',
				elements = elements},
				function(data2, menu2)
					TriggerServerEvent('yp_police:buyWeapon', data2.current.value, data2.current.cost)
				end,
				function(data2, menu2)
					menu2.close()
				end)
		end,
		function(data,menu)
			menu.close()
		end)
end

--Events
RegisterNetEvent('yp_police:playerReady')
AddEventHandler('yp_police:playerReady', function()
	playerReady = true
	TriggerServerEvent('yp_police:getUserJob')
end)

RegisterNetEvent('yp_police:openJobMenu')
AddEventHandler('yp_police:openJobMenu', function()
	openJobMenu()
end)

RegisterNetEvent('yp_police:viewId')
AddEventHandler('yp_police:viewId', function(data)

	if data.sex == 'm' then
		data.sex = 'Male'
	else
		data.sex = 'Female'
	end

	exports['mythic_notify']:DoLongHudText('inform', 'Name: ' .. data.firstname .. ' ' .. data.lastname)
	exports['mythic_notify']:DoLongHudText('inform', 'Job: ' .. data.job)
	exports['mythic_notify']:DoLongHudText('inform',  'DOB: ' .. data.dob)
  	exports['mythic_notify']:DoLongHudText('inform', 'Sex: ' .. data.sex)
  	exports['mythic_notify']:DoLongHudText('inform', 'Height: ' .. data.height .. 'cm')
end)

RegisterNetEvent('yp_police:showPlayerInv')
AddEventHandler('yp_police:showPlayerInv', function(invData)
	local inventory = invData.inventory
	local weapons = invData.weapons
	local accounts = invData.accounts

	local elements = {}
				  
	for i=1, #accounts, 1 do
		if accounts[i].name == 'black_money' and accounts[i].money > 0 then
			table.insert(elements, {
			label    = ('Dirty Money: $' .. tostring(ESX.Math.Round(accounts[i].money))),
			value    = 'black_money',
			amount   = ESX.Math.Round(accounts[i].money),
			itemType = 'account'
			})
			break
		end
	end
				  
	for i=1, #weapons, 1 do
		table.insert(elements, {
		label = (weapons[i].label .. ' [' .. tostring(weapons[i].ammo) .. ']'),
		value = weapons[i].name,
		amount = weapons[i].ammo,
		itemType = 'weapon'
		})
	end
				  
	for i=1, #inventory, 1 do
		if inventory[i].count > 0 then
			table.insert(elements, {
			label = (inventory[i].label .. ' x' .. tostring(inventory[i].count)),
			value = inventory[i].name,
			amount = inventory[i].count,
			itemType = 'item'
			})
		end
	end

	for i, v in pairs(elements) do
		print(v.label)
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'evidence_menu', {
		title = 'Evidence Locker',
		align = 'bottom-right', 
		elements = elements}, 
		function(data, menu)
			TriggerServerEvent('yp_police:depositItem', data.current.value, data.current.amount, data.current.itemType)
			TriggerServerEvent('yp_police:getInvData')
		end,
		function(data, menu)
			menu.close()
		end)
end)

RegisterNetEvent('yp_police:onDuty')
AddEventHandler('yp_police:onDuty', function()
	isPolice = true
end)

RegisterNetEvent('yp_police:offDuty')
AddEventHandler('yp_police:offDuty', function()
	isPolice = false
end)

--Main
Citizen.CreateThread(function()
	while not playerReady do
		Citizen.Wait(0)
	end
	local playerPed = GetPlayerPed(-1)
	local pos = nil

	while true do--Main Loop
		pos = GetEntityCoords(playerPed)

		--Draw Markers
		if Vdist(pos.x, pos.y, pos.z, 477.2778, -988.1365, 24.9147) < 20 then --Evidence Locker
			DrawMarker(1, 477.8778, -984.2165, 23.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if Vdist(pos.x, pos.y, pos.z, 452.0335, -980.3474, 30.6896) < 20 then -- Armory
			DrawMarker(1, 452.0335, -980.3474, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if Vdist(pos.x, pos.y, pos.z, 451.0890, -992.4544, 30.6896) < 20 then
			DrawMarker(1, 451.0890, -992.4544, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if Vdist(pos.x, pos.y, pos.z, 454.8623, -1017.3440, 28.4261) < 20 then -- Car Spawner
			DrawMarker(36, 454.8623, -1017.3440, 28.4261, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, false, 2, true, nil, nil, false)
		end

		--Listners
		if isPolice then
			if IsControlJustPressed(0, 167) then
				TriggerEvent('yp_police:openJobMenu')
			end

			if Vdist(pos.x, pos.y, pos.z, 477.8778, -984.2165, 24.9147) < 1 then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to access Deposit Evidence")
				if IsControlJustPressed(0,51) then
					TriggerServerEvent('yp_police:getInvData')
				end
						
			elseif Vdist(pos.x, pos.y, pos.z, 452.0335, -980.3474, 30.6896) < 1 then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to access the Armory")
				if IsControlJustPressed(0,51) then
					armoryMenu()
				end
			elseif Vdist(pos.x, pos.y, pos.z, 451.0890, -992.4544, 30.6896) < 1 then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to change your outfit")
				if IsControlJustPressed(0,51) then
					--Open Locker rooms
				end
			elseif Vdist(pos.x, pos.y, pos.z, 454.8623, -1017.3440, 28.4261) < 1 then -- Car Spawner
				DisplayHelpText("Press ~INPUT_CONTEXT~ to get a car")
				if IsControlJustPressed(0,51) then
					--Open Vehicle spawner
				end
			end
		end
			Citizen.Wait(0)
	end
end)
