--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

Citizen.CreateThread(function()
	
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

--Script Globals
local CurrentlyTowedVehicle = nil
local uiEnabled = false
local societyBalance = nil

SetNuiFocus(false, false)

--UI Functions
function enableUI(enable)
	SetNuiFocus(enable, enable)
	uiEnabled = enable
	SendNUIMessage({
		type = 'ui',
		enable = enable,
		societyBalance = societyBalance
	})
end

RegisterCommand('exitui', function()
	SetNuiFocus(false, false)
end)

RegisterNUICallback('exit', function(data, cb)
	enableUI(false)
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	print(data.value)
	TriggerServerEvent('yp_mechanic:withdrawSociety', data.value)
	enableUI(false)
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('yp_mechanic:depositSociety', data.value)
	enableUI(false)
	cb('ok')
end)

--Functions
function cleanCar()
	local playerPed = GetPlayerPed(-1)
	local vehicle = ESX.Game.GetVehicleInDirection()
	Citizen.CreateThread(function()
		TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
		exports['mythic_notify']:DoHudText('inform', 'Started Cleaning')
		exports['progressBars']:startUI(5000, "Cleaning car")
		Citizen.Wait(5000)
		ClearPedTasksImmediately(playerPed)
		exports['mythic_notify']:DoHudText('inform', 'Car Cleaned')
    end)
end

--Thanks ESX
function useFlatbed()
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, true)

	local towmodel = GetHashKey('flatbed')
	local isVehicleTow = IsVehicleModel(vehicle, towmodel)

	if isVehicleTow then
		local targetVehicle = ESX.Game.GetVehicleInDirection()

		if CurrentlyTowedVehicle == nil then
			if targetVehicle ~= 0 then
				if not IsPedInAnyVehicle(playerPed, true) then
					if vehicle ~= targetVehicle then
						AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
							CurrentlyTowedVehicle = targetVehicle
							exports['mythic_notify']:DoHudText('inform', 'Vehicle Attached')
					else
						exports['mythic_notify']:DoHudText('error', 'You cant attach your own vehicle')
					end
				end
			else
				exports['mythic_notify']:DoHudText('error', 'There is no vehicle to attach')
			end
		else
			AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
			DetachEntity(CurrentlyTowedVehicle, true, true)

			CurrentlyTowedVehicle = nil
			exports['mythic_notify']:DoHudText('inform', 'Vehicle detached')
		end
	else
		exports['mythic_notify']:DoHudText('error', 'You need to be in a flatbed')
	end
end

function openJobMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mechjob_menu', {
		title = 'Mechanic',
		align = 'bottom-right',
		elements = {
			{label = 'Billing', value = 'billing'},
			{label = 'Repair', value = 'repair'},
			{label = 'Lockpick', value = 'lockpick'},
			{label = 'Flatbed', value = 'flatbed'},
			{label = 'Clean', value = 'clean'},
			{label = 'Impound', value = 'impound'},
			{label = 'Object Spawner', value = 'spawner'}
		}},
		function(data, menu)
			local action = data.current.value
			if action == 'billing' then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fine_player', {title = 'Enter Bill Amount'},
					function(data2, menu2)
						menu2.close()
						local closestPlayer, distance = ESX.Game.GetClosestPlayer()
						if (closestPlayer ~= -1 and distance < 3.0) then
							TriggerServerEvent('yp_mechanic:chargePlayer', GetPlayerServerId(closestPlayer), tonumber(data2.value))
						else
							exports['mythic_notify']:DoHudText('error', 'There is no player nearby!')
						end
					end,
					function(data2, menu2)
						menu2.close()	
					end)
			elseif action == 'repair' then
				TriggerEvent('yp_mechanic:repairCar')
			elseif action == 'lockpick' then
				TriggerEvent('yp_userinteraction:lockpickvehicle')
			elseif action == 'flatbed' then
				useFlatbed()
			elseif action == 'clean' then
				cleanCar()
			elseif action == 'impound' then
				local vehicle = ESX.Game.GetVehicleInDirection()
				if DoesEntityExist(vehicle) then
					Citizen.CreateThread(function()
						local playerPed = GetPlayerPed(-1)
						exports['progressBars']:startUI(10000, "Impounding...")
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_KNEEL', 0, true)
					    Citizen.Wait(10000)
					    ClearPedTasksImmediately(playerPed)
					    exports['mythic_notify']:DoHudText('inform', 'Vehicle Impounded')
					    ESX.Game.DeleteVehicle(vehicle)
					end)
				end
			end
		end,
		function(data,menu)
			menu.close()
		end)
end

function repairVehicle()
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local veh = GetVehiclePedIsIn(playerPed)
		local engine = GetVehicleEngineHealth(veh)
		local body = GetVehicleBodyHealth(veh)
		local price = (BasePrice/2 * ((1000 - body) / 1000.0 + 1)) + (BasePrice/2 * ((1000 - engine) / 1000.0 + 1))
		if DoesEntityExist(veh) then
			exports['mythic_notify']:DoHudText('inform', 'You are repairing the vehicle')
			exports['progressBars']:startUI(RepairTime, 'Repairing')
			Citizen.Wait(RepairTime)
			SetVehicleEngineHealth(veh, 1000.0)
			SetVehicleBodyHealth(veh, 1000.0)
			SetVehicleDeformationFixed(veh)

			for i = 0, 5, 1 do
				SetVehicleTyreFixed(veh, i)
			end

			exports['mythic_notify']:DoHudText('success', 'You repaired your vehicle')

			TriggerServerEvent('yp_mechanic:chargeForRepair', price)
		end
	end)
end

--Events
RegisterNetEvent('yp_mechanic:openJobMenu')
AddEventHandler('yp_mechanic:openJobMenu', function()
	openJobMenu()
end)

RegisterNetEvent('yp_mechanic:repairCar')
AddEventHandler('yp_mechanic:repairCar', function()
	Citizen.CreateThread(function()
		local veh = ESX.Game.GetVehicleInDirection()
		local playerPed = GetPlayerPed(-1)
		if DoesEntityExist(veh) then
			exports['mythic_notify']:DoHudText('inform', 'You are repairing the vehicle')
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			exports['progressBars']:startUI(10000, "Repairing Vehicle")
			Citizen.Wait(10000)
			SetVehicleEngineHealth(veh, 1000.0)
			SetVehicleBodyHealth(veh, 1000.0)
			exports['mythic_notify']:DoHudText('success', 'You repaired your vehicle')
			SetVehicleDeformationFixed(veh)
			ClearPedTasksImmediately(playerPed)
		end
	end)
end)

RegisterNetEvent('yp_mechanic:updateSocietyBalance')
AddEventHandler('yp_mechanic:updateSocietyBalance', function(amount)
	societyBalance = amount
	enableUI(true)
end)

RegisterNetEvent('yp_mechanic:repairEngine')
AddEventHandler('yp_mechanic:repairEngine', function()
	Citizen.CreateThread(function()
	  	local vehicle = ESX.Game.GetVehicleInDirection()
	  	local playerPed = GetPlayerPed(-1)
	  	if DoesEntityExist(vehicle) then
	  		if not (GetVehicleEngineHealth(vehicle) >= 950.0 and GetVehicleBodyHealth(vehicle) == 1000.0) then
		  		exports['mythic_notify']:DoHudText('inform', 'You are repairing your vehicle')
		      	TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
		      	exports['progressBars']:startUI(7000, "Repairing vehicle")
		      	Citizen.Wait(7000)
		      	SetVehicleEngineHealth(vehicle, 1000.0)
		      	SetVehicleBodyHealth(vehicle, 1000.0)
		      	SetVehicleDeformationFixed(vehicle)
		      	ClearPedTasksImmediately(playerPed)
		      	exports['mythic_notify']:DoLongHudText('success', 'You repaired your vehicle')
		      	TriggerServerEvent('yp_base:removeItem', 'advrepair', 1)
		    else
		      	exports['mythic_notify']:DoLongHudText('error', 'Your vehicle is not damaged')
		    end
	  	end
	end)
end)

--Main thread
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed))

		if ESX.PlayerData.job.name == 'mechanic' then
			if IsControlJustPressed(0,167) then
				openJobMenu()
			end
		end

		for i, v in ipairs(Shops) do
			if Vdist(x, y, z , v.funds.x, v.funds.y, v.funds.z) < 20 then
				DrawMarker(1, v.funds.x, v.funds.y, v.funds.z -1 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z , v.funds.x, v.funds.y, v.funds.z) < 1 then
					if ESX.PlayerData.job.grade_name == 'boss' then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to access mechanic funds')
						if IsControlJustPressed(0, 51) then
							TriggerServerEvent('yp_mechanic:getSocietyMoney')
						end
					else
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to deposit funds')
						if IsControlJustPressed(0, 51) then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_money', {title = 'Amount to deposit'},
								function(data, menu)
									if tonumber(data.value) > 0 then
										menu.close()
										TriggerServerEvent('yp_mechanic:depositMoney', tonumber(data.value))
									end
								end,
								function(data, menu)
									menu.close()
								end)
						end
					end
				end
			end

			if Vdist(x, y, z, v.crafting.x, v.crafting.y, v.crafting.z) < 20 then
				DrawMarker(1, v.crafting.x, v.crafting.y, v.crafting.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.crafting.x, v.crafting.y, v.crafting.z) < 1 then
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to craft repair kit')
					if IsControlJustPressed(0, 51) then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'repair_amount', {title = "Amount of Kits"},
							function(data, menu)
								local amount = tonumber(data.value)
								if amount > 0 and amount <= 5 then
									menu.close()
									TriggerServerEvent('yp_mechanic:craftRepairKit', amount)
								end
							end,
							function(data, menu)
								menu.close()
							end)
					end
				end
			end

			if Vdist(x, y, z, v.spawn.x, v.spawn.y, v.spawn.z) < 20 then
				DrawMarker(1, v.spawn.x, v.spawn.y, v.spawn.z - 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 1.0, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.spawn.x, v.spawn.y, v.spawn.z) < 3 then
					if IsPedInAnyVehicle(playerPed, false) then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to put away vehicle')
						if IsControlJustPressed(0, 51) then
							local vehicle = GetVehiclePedIsIn(playerPed)
							ESX.Game.DeleteVehicle(vehicle)
						end
					else
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to grab a vehicle')
						if IsControlJustPressed(0, 51) then 
							local elements = Vehicles
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu',{
								title = 'Vehicles',
								align = 'bottom-right',
								elements = elements},
								function(data, menu)
									menu.close()
									local vehicle = GetHashKey(data.current.value)
									RequestModel(vehicle)
									while not HasModelLoaded(vehicle) do
										Citizen.Wait(0)
									end
									CreateVehicle(vehicle, v.vehLoc.x, v.vehLoc.y, v.vehLoc.z, 1, true, true)
								end,
								function(data, menu)
									menu.close()
								end)
						end
					end
				end
			end
		end

		if IsPedInAnyVehicle(playerPed) then
			for i, v in ipairs(RepairModels) do
				local object = GetClosestObjectOfType(x, y, z, 3.75, v)
				if DoesEntityExist(object) then
					local objPos = GetEntityCoords(object)
					if Vdist(x, y, z, objPos.x, objPos.y, objPos.z) < 3.75 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to repair your car')
						if IsControlJustPressed(0, 51) then
							repairVehicle()
						end
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end)
