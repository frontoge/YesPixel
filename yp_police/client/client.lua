--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local inUniform = false
local isBoss = false
local invData = {}
local pdBlip = nil


--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
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
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fine_player', {title = 'Enter Fine Amount'},
						function(data3, menu3)
							menu3.close()
							local closestPlayer, distance = ESX.Game.GetClosestPlayer()
							if (closestPlayer ~= -1 and distance < 3.0) then
								TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_city', 'PD Fine', data3.value)
							else
								exports['mythic_notify']:DoHudText('error', 'There is no player nearby!')
							end
						end,
						function(data3, menu3)

						end)
				else--Jailmenu
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if (closestPlayer ~= -1 and distance < 3.0) then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'jail_player', {title = 'Enter duration'},
							function(data3, menu3)
								menu3.close()
								if tonumber(data3.value) > 0 then
									TriggerServerEvent('esx_jail:sendToJail', GetPlayerServerId(closestPlayer), data3.value)
								else
									exports['mythic_notify']:DoHudText('error', "Can't jail for less than 0 months")
								end
							end,
							function(data3, menu3)
								menu3.close()
							end)
					else
						exports['mythic_notify']:DoHudText('error', 'There is no player nearby!')
					end
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
					{label = 'Search Glovebox', value = 'search_glovebox'},
					{label = 'Lockpick', value = 'lockpick'}
				}},
			function(data2, menu2)
				local action2 = data2.current.value
				if action2 == 'registration' then
					local pos = GetEntityCoords(GetPlayerPed(-1))
					local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 3.0, 0, 70)
					if vehicle ~= nil then
						TriggerServerEvent('yp_police:getRegistration', GetVehicleNumberPlateText(vehicle))
					else
						exports['mythic_notify']:DoHudText('error', 'No vehicle nearby!')
					end


				elseif action2 == 'impound' then
					local vehicle = ESX.Game.GetVehicleInDirection()
					if DoesEntityExist(vehicle) then
						Citizen.CreateThread(function()
							local playerPed = GetPlayerPed(-1)
							exports['progressBars']:startUI(10000, "Impounding...")
							TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
					        Citizen.Wait(10000)
					        ClearPedTasksImmediately(playerPed)
					        ESX.Game.DeleteVehicle(vehicle)
						end)
						
					else
						exports['mythic_notify']:DoHudText('error', 'There is no vehicle nearby')
					end
				elseif action2 == 'search_glovebox' then

				else
					TriggerEvent('yp_userinteraction:lockpickvehicle')

				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif action == 'object' then
			local elements = pdObjects
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'object_spawner', {
				title = 'Object Spawner',
				align = 'bottom-right',
				elements = elements},
				function(data2, menu2)
					local playerPed = GetPlayerPed(-1)
					local coords = GetEntityCoords(playerPed)
					local forward = GetEntityForwardVector(playerPed)
					local x, y, z = table.unpack(coords + forward * 1.0)

					ESX.Game.SpawnObject(data2.current.value, {x = x, y = y, z = z}, function(obj)
					SetEntityHeading(obj, GetEntityHeading(playerPed))
					PlaceObjectOnGroundProperly(obj)
					end)
				end,
				function(data2, menu2)
					menu2.close()
				end)
		else
			TriggerServerEvent('startCad')
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

function vehicleMenu()
	local elements = pdVehicles
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
		title = 'Vehicle Spawner',
		align = 'bottom-right', 
		elements = elements},

		function(data, menu)
			Citizen.CreateThread(function()
				local vehicle = GetHashKey(data.current.value)
				RequestModel(vehicle)
				while not HasModelLoaded(vehicle) do
					Citizen.Wait(0)
				end
				CreateVehicle(vehicle, 442.6445, -1018.7537, 28.6769, 1.0, true, true)
			end)
		end,
		function(data, menu)
			menu.close()
		end)
end

function medicalMenu()
	local elements = medSupplies
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'medical_menu', {
		title = 'Medical Supplies',
		align = 'bottom-right',
		elements = elements},
		function(data, menu)
			TriggerServerEvent('yp_police:buyMeds', data.current.value, data.current.cost)
		end,
		function(data, menu)
			menu.close()
		end)
end

function healPlayer()
	local ped = GetPlayerPed(-1)
	Citizen.CreateThread(function()
		DoScreenFadeOut(2000)
		Citizen.Wait(11000)
		SetEntityHealth(ped, GetEntityMaxHealth(ped))
		DoScreenFadeIn(2000)
	end)
end

function heliMenu()
	Citizen.CreateThread(function()
		local vehicle = GetHashKey('polmav')
		RequestModel(vehicle)
		while not HasModelLoaded(vehicle) do
			Citizen.Wait(0)
		end
		CreateVehicle(vehicle, 449.3225, -981.2054, 43.6917, 1.0, true, true)
	end)
end


--Events
RegisterNetEvent('yp_police:playerReady')
AddEventHandler('yp_police:playerReady', function()
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
	if not isPolice then
		isPolice = true
		exports['mythic_notify']:DoHudText('success', 'You are now on duty!')
	else
		exports['mythic_notify']:DoHudText('error', 'You are already on duty!')
	end
end)

RegisterNetEvent('yp_police:offDuty')
AddEventHandler('yp_police:offDuty', function()
	if isPolice then
		isPolice = false
		exports['mythic_notify']:DoHudText('error', 'You are now off duty!')
	else
		exports['mythic_notify']:DoHudText('error', 'You are already off duty!')
	end
end)

RegisterNetEvent('yp_police:changeUniform')
AddEventHandler('yp_police:changeUniform', function(skin)
	TriggerEvent('skinchanger:loadSkin', skin)

	inUniform = true
end)

RegisterNetEvent('yp_police:outUniform')
AddEventHandler('yp_police:outUniform', function(skin)
	TriggerEvent('skinchanger:loadSkin', skin)
	inUniform = false

end)

RegisterNetEvent('yp_police:getHired')
AddEventHandler('yp_police:getHired', function()
	isPolice = true
end)

RegisterNetEvent('yp_police:makeBoss')
AddEventHandler('yp_police:makeBoss', function()
	isBoss = true
end)

RegisterNetEvent('yp_police:showPlayerName')
AddEventHandler('yp_police:showPlayerName', function(name)
	exports['mythic_notify']:DoHudText('inform', 'This vehicle belongs to ' .. name)
end)

RegisterNetEvent('yp_police:setJob')
AddEventHandler('yp_police:setJob', function(status)
	isPolice = status
end)

--Main
Citizen.CreateThread(function()
	Citizen.Wait(500)
	local pos = nil

	while true do--Main Loop
		local playerPed = GetPlayerPed(-1)
		pos = GetEntityCoords(playerPed)

		--Draw Markers
		if ESX.PlayerData.job.name == 'police' then
			if Vdist(pos.x, pos.y, pos.z, 477.2778, -988.1365, 24.9147) < 20 then --Evidence Locker
				DrawMarker(1, 477.8778, -984.2165, 23.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 452.0335, -980.3474, 30.6896) < 20 then -- Armory
				DrawMarker(1, 452.0335, -980.3474, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 451.0890, -992.4544, 30.6896) < 20 then -- Locker room
				DrawMarker(1, 451.0890, -992.4544, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 454.8623, -1017.3440, 28.4261) < 30 then -- Car Spawner
				DrawMarker(36, 454.8623, -1017.3440, 28.4261, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, false, 2, true, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 463.4964, -982.4035, 43.6920) < 30 then -- Heli Spawner 
				DrawMarker(34, 463.4964, -982.4035, 43.6920, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, false, 2, true, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 462.7208, -1017.0921, 28.0829) < 20 then -- Car Return
				DrawMarker(1, 462.7208, -1017.0921, 27.0829, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.5, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 459.5682, -975.8306, 35.9310) < 20 then -- on/off duty
				DrawMarker(1, 459.5682, -975.8306, 34.9310, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			end

			if Vdist(pos.x, pos.y, pos.z, 435.8352, -973.4408, 26.6685) < 20 then -- Medical supply room
				DrawMarker(1, 435.8352, -973.4408, 25.6685, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			end

		--Listners
		
			if IsControlJustPressed(0, 167) then
				openJobMenu()
			end

			local objects = pdObjects
			for i, v in ipairs(objects) do
				local entity = GetClosestObjectOfType(pos.x, pos.y, pos.z, 3.0, GetHashKey(v.value))
				if entity ~= 0 then
					DisplayHelpText('Press ~INPUT_CONTEXT~ to Delete Object')				
					if IsControlJustPressed(0,51) then
						ESX.Game.DeleteObject(entity)
					end
				end
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
					if not inUniform then
						TriggerServerEvent('yp_police:getUniform')
						exports['mythic_notify']:DoHudText('inform', 'You are now in uniform.')
					else
						TriggerServerEvent('yp_police:getPlainSkin')
						exports['mythic_notify']:DoHudText('inform', 'You are now out of uniform.')
					end
				end
			elseif Vdist(pos.x, pos.y, pos.z, 454.8623, -1017.3440, 28.4261) < 1 then -- Car Spawner
				DisplayHelpText("Press ~INPUT_CONTEXT~ to get a car")
				if IsControlJustPressed(0,51) then
					vehicleMenu()
				end	
			elseif Vdist(pos.x, pos.y, pos.z, 439.3706, -976.5902, 26.6685) < 1 then --Heal spot
				DisplayHelpText("Press ~INPUT_CONTEXT~ to get medical treatment")
				if IsControlJustPressed(0,51) then
					healPlayer()
				end
			elseif Vdist(pos.x, pos.y, pos.z, 435.8352, -973.4408, 26.6685) < 1 then --Medical supplies
				DisplayHelpText("Press ~INPUT_CONTEXT~ to get medical supplies")
				if IsControlJustPressed(0,51) then
					medicalMenu()
				end
			elseif Vdist(pos.x, pos.y, pos.z, 463.4964, -982.4035, 43.6920) < 1 then -- Heli Spawner
				DisplayHelpText("Press ~INPUT_CONTEXT~ to get a helicopter")
				if IsControlJustPressed(0,51) then
					heliMenu()
				end
			end

			if IsPedInAnyVehicle(playerPed, false) then
				local vehicle = ESX.Game.GetClosestVehicle()
				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					if Vdist(pos.x, pos.y, pos.z, 462.7208, -1017.0921, 28.0829) < 3 then
						DisplayHelpText("Press ~INPUT_CONTEXT~ to return a vehicle")
						if IsControlJustPressed(0,51) then
							ESX.Game.DeleteVehicle(vehicle)
						end
					end
				end
			end
		end

		if Vdist(pos.x, pos.y, pos.z, 459.5682, -975.8306, 35.9310) < 1 then -- on/offduty
			if isPolice then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to go Off Duty")
				
			else
				DisplayHelpText("Press ~INPUT_CONTEXT~ to go On Duty")
			end
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_police:toggleDuty', isPolice)
			end
		end

		if isBoss and Vdist(pos.x, pos.y, pos.z, 461.8731, -1007.7943, 35.9311) < 1 then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to hire someone")
			if IsControlJustPressed(0,51) then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'id_input', {title = 'Enter ID of Player'},
					function(data, menu)
						menu.close()
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'grade_input', {title = 'Enter Job Grade'},
							function(data2, menu2)
								menu2.close()
								TriggerServerEvent('yp_police:hirePlayer', tonumber(data.value), tonumber(data2.value))
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
		Citizen.Wait(0)
	end
end)
