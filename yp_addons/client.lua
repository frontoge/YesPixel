--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('yp_addons:placeCone')
AddEventHandler('yp_addons:placeCone', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)
	local forward = GetEntityForwardVector(playerPed)
	local x, y, z = table.unpack(coords + forward * 1.0)

	ESX.Game.SpawnObject('prop_roadcone02a', {x = x, y = y, z = z}, function(obj)
		SetEntityHeading(obj, GetEntityHeading(playerPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		--Vending machines
		local machines = vendingMachines
		for i, v in pairs(vendingMachines) do
			if Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 1 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to use the vending machine $' .. vendingCost)
				if IsControlJustPressed(0,51) then
					local elements = {}
					if v.kind == 'food' then
						elements = vendingFood
					elseif v.kind == 'soda' then
						elements = vendingDrink
					else
						TriggerServerEvent('yp_addons:buyVendItem', 'donut')
					end
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vending_food_menu', {title = 'Vending Machine', align = 'bottom-right', elements = elements},
						function(data, menu)
							menu.close()
							TriggerServerEvent('yp_addons:buyVendItem', data.current.value)
						end,
						function(data, menu)
							menu.close()
						end)
				end
				break
			end
		end
		Citizen.Wait(0)
	end
end)