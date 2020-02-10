--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

blip = nil

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function openHospitalShop()
	local elements = EMSItems
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'hospital_shop', {
		title = 'Hospital',
		align = 'bottom-right',
		elements = elements},
		function(data, menu)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'amount', {title = 'how many'},
				function(data2, menu2)
					local amount = tonumber(data2.value)
					if amount > 0 then
						menu2.close()
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'checkout_menu', {
							title = 'Checkout',
							align = 'bottom-right',
							elements = {
								{label = 'Pay with Cash', value = 'cash'},
								{label = 'Pay with Card', value = 'card'}
							}
						},
						function(data3, menu3)
							menu3.close()
							local card = true
							if data3.current.value == 'cash' then
								card = false
							end
							TriggerServerEvent('yp_ems:payForItems', card, amount, data.current.value, data.current.price*amount)
						end,
						function(data3, menu3)
							menu3.close()
						end)
					else
						exports['mythic_notify']:DoHudText('error', 'Amount cannot be less than 0')
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

function openVehicleMenu(spawnPos)
	local elements = Vehicles 
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_spawner', {
		title = 'Vehicles',
		align = 'bottom-right',
		elements = elements
	},
	function(data, menu)
		menu.close()
		Citizen.CreateThread(function()
			print('hello')
			local vehicle = GetHashKey(data.current.value)
			RequestModel(vehicle)
			while not HasModelLoaded(vehicle) do
				Citizen.Wait(0)
			end
			CreateVehicle(vehicle, spawnPos.x, spawnPos.y, spawnPos.z, -90.0, true, true)
		end)
	end,
	function(data, menu)
		menu.close()
	end)
end

function openSupplyMenu()
	local elements = SupplyItems
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ems_supply', {
		title = 'Supplies',
		align = 'bottom-right',
		elements = elements},
		function(data, menu)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ems_supply_amount', {title = 'Enter amount'}, 
				function(data2, menu2)
					TriggerServerEvent('yp_base:addItem', data.current.value, data2.value)
					TriggerServerEvent('esx_addonaccount:getSharedAccount', 'society_city', function(account)
				        account.removeMoney(data2.value * data.current.value)
				    end)
				    menu2.close()
				end,
				function(data2, menu2)
					menu2.close()
				end)
		end,
		function(data, menu)
			menu.close()
		end)
end

RegisterNetEvent('yp_ems:doCPR')
AddEventHandler("yp_ems:doCPR", function(ems)
	Citizen.CreateThread(function()
		local closestPlayer, distance = ESX.Game.GetClosestPlayer()
		local playerPed = GetPlayerPed(-1)
		if closestPlayer ~= -1 and distance < 3 then
			if IsPedDeadOrDying(GetPlayerPed(closestPlayer)) then
				if not ems then
					loadAnimDict('mini@cpr@char_a@cpr_str')
					exports['mythic_notify']:DoHudText('inform', 'Started CPR')
					exports['progressBars']:startUI(15000, 'Performing CPR')

					for i = 0, 30, 1 do
						TaskPlayAnim(playerPed, "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, -8.0, -1, 0, 0, false, false, false)
						Citizen.Wait(500)
					end

					TriggerServerEvent('yp_ems:revivePlayer', GetPlayerServerId(closestPlayer))
				else
					exports['mythic_notify']:DoHudText('inform', 'This persons wounds are too severe for you to help.', 3500)
				end
				ClearPedSecondaryTask(playerPed)
			else
				exports['mythic_notify']:DoHudText('error', "This person does not need CPR")
			end
		else
			exports['mythic_notify']:DoHudText('error', 'No one nearby')
		end
	end)
end)

Citizen.CreateThread(function()
	blip = AddBlipForCoord(319.7480, -593.4249, 43.2918)
	SetBlipSprite(blip, 153)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.5)
	SetBlipColour(blip, 1)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Hospital")
	EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()

	local pos = nil
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
		--Main thread
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed))
		--Shops
		for i, v in ipairs(BuyLocations) do
			if Vdist(x, y, z, v.x, v.y, v.z) < 20 then
				DrawMarker(1, v.x, v.y, v.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.x, v.y, v.z) < 1.5 then
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to shop')
					if IsControlJustPressed(0, 51) then
						openHospitalShop()
					end
				end
			end
		end

		--Teleports
		for i, v in ipairs(Teleports) do
			if Vdist(x, y, z, v.start.x, v.start.y, v.start.z) < 40 then
				DrawMarker(1, v.start.x, v.start.y, v.start.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.5, 0, 255, 180, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.start.x, v.start.y, v.start.z) < 1.5 then
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ ' .. v.message)
					if IsControlJustPressed(0, 51) then
						SetEntityCoords(playerPed, tonumber(v.dest.x), tonumber(v.dest.y), tonumber(v.dest.z) , 1, 0, 0, 1)
					end
				end
			end
		end

		if ESX.PlayerData.job.name == 'ems' then

			--Vehicle Spawner
			for i, v in ipairs(VehicleSpawners) do
				if Vdist(x, y, z, v.marker.x, v.marker.y, v.marker.z) < 40 then
					DrawMarker(36, v.marker.x, v.marker.y, v.marker.z, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 180, 100, false, false, 2, true, nil, nil, false)
					if Vdist(x, y, z, v.marker.x, v.marker.y, v.marker.z) < 1.0 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to grab a car')
						if IsControlJustPressed(0, 51) then
							openVehicleMenu(v.spawn)
						end
					end
				end
			end

			--Vehicle Returns
			for i, v in ipairs(VehicleDrops) do
				if Vdist(x, y, z, v.x, v.y, v.z) < 40 then
					DrawMarker(1, v.x, v.y, v.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 0.5, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
					if IsPedInAnyVehicle(playerPed) then
						if Vdist(x, y, z, v.x, v.y, v.z) < 3 then
							exports['yp_base']:DisplayHelpText("Press ~INPUT_CONTEXT~ to return the vehicle")
							if IsControlJustPressed(0, 51) then
								local vehicle = GetVehiclePedIsIn(playerPed)
								if GetPedInVehicleSeat(vehicle, -1) == playerPed then
									exports['yp_base']:deleteVehicle(vehicle)
								end
							end
						end
					end
				end
			end

			for i, v in ipairs(SupplyClosets) do --Supply Closet
				if Vdist(x, y, z, v.x, v.y, v.z) < 40 then
					DrawMarker(1, v.x, v.y, v.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 0, 255, 255, 100, false, false, 2, false, nil, nil, false)
					if Vdist(x, y, z, v.x, v.y, v.z) < 1.5 then
						exports['yp_base']:DisplayHelpText("Press ~INPUT_CONTEXT~ to get supplies")
						if IsControlJustPressed(0, 51) then
							openSupplyMenu()
						end
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end)