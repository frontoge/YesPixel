--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

--Mod enum
local vehMods =
{
	[0] = "modSpoilers",
	"modFrontBumper",
	"modRearBumper",
	"modSideSkirt",
	"modExhaust",
	"modFrame",
	"modGrille",
	"modHood",
	"modFender",
	"modRightFender",
	"modRoof",
	"modEngine",
	"modBrakes",
	"modTransmisson",
	"Horns",
	"modSuspension",
	"modArmor",
	"UNK17",
	'modTurbo',
	'UNK19',
	'modSmokeEnabled',
	'UNK21',
	'modXenon',
	"modFrontWheels",
	"modBackWheels",
	"modPlateHolder",
	"modVanityPlate",
	"modTrimA",
	"modOrnaments",
	'modDashboard',
	"modDial",
	'modDoorSpeaker',
	'modSeats',
	"modSteeringWheel",
	"modShifterLeavers",
	'modAPlate',
	'modSpeakers',
	'modTrunk',
	"modHydrolic",
	'modEngineBlock',
	'modAirFilter',
	'modStruts',
	'modArchCover',
	'modAerials',
	'modTrimB',
	'modTank',
	'modWindows',
	'UNK47',
	"modLivery"
}

local garageBlips = {}

function modelVehicle(vehicle, list, plate)--Called when spawning vehicle
	local color1 = list.color1
	local color2 = list.color2
	local tint = list.windowTint
	SetVehicleNumberPlateText(vehicle, plate)

	SetVehicleColours(vehicle, color1, color2)

	if tint ~= -1 then
		SetVehicleWindowTint(vehicle, tint)
	end

	SetVehicleEngineHealth(vehicle, tonumber(list.engineHealth))
	SetVehicleBodyHealth(vehicle, tonumber(list.bodyHealth))
	SetVehiclePetrolTankHealth(vehicle, tonumber(list.fuelTankHealth))
	SetVehicleFuelLevel(vehicle, tonumber(list.fuelLevel))
	DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))

	--Add Mods 
	SetVehicleModKit(vehicle, 0)
	for i = 0, #vehMods, 1 do
		local value = list[vehMods[i]]
		if value == 'true' then
			ToggleVehicleMod(vehicle, i, true)
		elseif value == 'false' then
			ToggleVehicleMod(vehicle, i, true)
		else
			SetVehicleMod(vehicle, i, tonumber(value)) --May need to be i-1 if there are issues
		end
	end
end

function getVehicleData(vehicle)--Called when storing vehicle, gets all the vehicleMods
	local data = {}
	local c1, c2 = GetVehicleColours(vehicle)
	data['color1'] = c1
	data['color2'] = c2
	data['windowTint'] = GetVehicleWindowTint(vehicle)
	data['model'] = GetEntityModel(vehicle)
	data['engineHealth'] = GetVehicleEngineHealth(vehicle)
	data['bodyHealth'] = GetVehicleBodyHealth(vehicle)
	data['fuelTankHealth'] = GetVehiclePetrolTankHealth(vehicle)
	data['plate'] = GetVehicleNumberPlateText(vehicle)
	data['fuelLevel'] = GetVehicleFuelLevel(vehicle)


	for i = 0, #vehMods, 1 do
		if string.find(vehMods[i], 'UNK') == nil then
			local temp = GetVehicleMod(vehicle, i)
			data[vehMods[i]] = temp
		end
	end

	return data

end

RegisterCommand('showMods', function(source, args)
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
	local c1, c2 = GetVehicleColours(vehicle)

	for i = 0, #vehMods, 1 do
		if string.find(vehMods[i], 'UNK') == nil then
			print(vehMods[i] .. ' ' .. GetVehicleMod(vehicle, i))
		end
	end
	print('color1 ' .. c1)
	print('color2 ' .. c2)
	print('windowTint ' .. GetVehicleWindowTint(vehicle))
end, false)

RegisterNetEvent('yp_garage:deleteCar')
AddEventHandler('yp_garage:deleteCar', function()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
	exports['yp_base']:deleteVehicle(vehicle)
end)

RegisterNetEvent('yp_garage:openVehicleMenu')
AddEventHandler('yp_garage:openVehicleMenu', function(data)
	local elements = data
	local vehicle = nil
	Citizen.CreateThread(function()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pull_out', {
			title = 'Vehicles',
			align = 'bottom-right',
			elements = elements},
			function(data, menu)
				menu.close()
				local action = data.current.value
				if action ~= 'not_stored' then
					local props = json.decode(action)
					local model = props.model
					local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
					RequestModel(model)
					while not HasModelLoaded(model) do
						Citizen.Wait(0)
					end
					vehicle = CreateVehicle(model, x, y, z, 165.0, true, true)
					TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
					TriggerServerEvent('yp_garage:pullVehicle', data.current.plate)
					modelVehicle(vehicle, props, data.current.plate)
					
				else
					exports['mythic_notify']:DoHudText('error', 'This vehicle is already outside')
				end
			end,
			function(data, menu)
				menu.close()
			end)
	end)
end)

RegisterNetEvent('yp_garage:openInsureMenu')
AddEventHandler('yp_garage:openInsureMenu', function(data, garageName)
	local elements = data

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insure_menu', {
		title = 'Vehicles',
		align = 'bottom-right',
		elements = elements},

		function(data, menu)
			local action = data.current
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_type', {
				title = 'Vehicles',
				align = 'bottom-right',
				elements = 
				{
					{label = 'Manage', value = 'manage'},
					{label = 'Rename', value = 'rename'}
				}},

				function(data2, menu2)
					if data2.current.value == 'manage' then --Move/Insure Vehicles
						if action.value == 'out' then
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insureveh', {
								title = 'Pay ($' .. InsurePrice .. ') to insure?',
								align = 'bottom-right',
								elements = 
								{
									{label = 'Yes', value = 'y'},
									{label = 'No', value = 'n'}
								}},

								function(data3, menu3)
									local action2 = data3.current.value
									if action2 == 'y' then
										TriggerServerEvent('yp_garage:storeVehicle', action.plate, garageName, nil)
										TriggerServerEvent('yp_base:payFee', InsurePrice)
										menu2.close()
										menu3.close()
									else
										menu2.close()
										menu3.close()
									end
								end,
								function(data3, menu3)

								end)
						else
							if action.value ~= garageName then
								ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'moveveh',{
									title = 'Pay ($' .. MovePrice .. ') to move here?',
									align = 'bottom-right',
									elements =
									{
										{label = 'Yes', value = 'y'},
										{label = 'No', value = 'n'}
									}},
									function(data3, menu3)
										local action2 = data3.current.value
										if action2 == 'y' then
											TriggerServerEvent('yp_garage:storeVehicle', action.plate, garageName, nil)
											TriggerServerEvent('yp_base:payFee', MovePrice)
											menu2.close()
											menu3.close()
										else
											menu2.close()
											menu3.close()
										end
									end,
									function(data3, menu3)

									end)
							else
								exports['mythic_notify']:DoHudText('inform', 'This vehicle is already here.')
							end
						end
					else
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_option', {title = 'New Name'},
							function(data3, menu3)
								TriggerServerEvent('yp_garage:renameVehicle', action.plate, data3.value)
								menu2.close()
								menu3.close()
							end,
							function(data3, menu3)
								menu2.close()
								menu3.close()
							end)
					end
				end,
				function(data2, menu2)
					menu2.close()
				end)

			
		end,
		function(data, menu)
			menu.close()
		end)

end)

--Create Blips 
Citizen.CreateThread(function()
	for i, v in ipairs(Garages) do
		garageBlips[i] = AddBlipForCoord(v.pick.x, v.pick.y, v.pick.z)
		SetBlipSprite(garageBlips[i], 50)
		SetBlipDisplay(garageBlips[i], 4)
		SetBlipScale(garageBlips[i], 1.0)
		SetBlipColour(garageBlips[i], 3)
		SetBlipAsShortRange(garageBlips[i], true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garage")
		EndTextCommandSetBlipName(garageBlips[i])
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed))

		for i, v in ipairs(Garages) do
			--Drop offs
			if Vdist(x, y, z, v.drop.x, v.drop.y, v.drop.z) < 25 then
				DrawMarker(1, v.drop.x, v.drop.y, v.drop.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.drop.x, v.drop.y, v.drop.z) < 2 then
					if IsPedInAnyVehicle(playerPed) then
						local vehicle = GetVehiclePedIsIn(playerPed)
						if GetPedInVehicleSeat(vehicle, -1) == playerPed then
							exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to put away this vehicle')
							if IsControlJustPressed(0, 51) then
								--Store Vehicle Data and check that the car is theirs first
								--Or maybe not check tbh
								local plateNum = GetVehicleNumberPlateText(vehicle)
								local vehData = getVehicleData(vehicle)
								TriggerServerEvent('yp_garage:storeVehicle', plateNum, v.name, vehData)
							end
						end
					end
				end
			end

			--Pickup
			if Vdist(x, y, z, v.pick.x, v.pick.y, v.pick.z) < 25 then
				DrawMarker(1, v.pick.x, v.pick.y, v.pick.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
				if Vdist(x, y, z, v.pick.x, v.pick.y, v.pick.z) < 2 then
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to grab a vehicle')
					if IsControlJustPressed(0, 51) then
						TriggerServerEvent('yp_garage:getVehicles', v.name)
					end
				end
			end

			--insure
			if v.insure ~= nil then
				if Vdist(x, y, z, v.insure.x, v.insure.y, v.insure.z) < 25 then
					DrawMarker(21, v.insure.x, v.insure.y, v.insure.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, 0.75, 0.75, 255, 204, 0, 100, false, false, 2, true, nil, nil, false)
					if Vdist(x, y, z, v.insure.x, v.insure.y, v.insure.z) < 1 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to manage vehicles')
						if IsControlJustPressed(0, 51) then
							TriggerServerEvent('yp_garage:getAllVehicles', v.name)
						end
					end
				end
			end

		end

		Citizen.Wait(0)
	end
end)