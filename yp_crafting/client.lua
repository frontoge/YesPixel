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

local researched = false

--Events
RegisterNetEvent('yp_crafting:startCraftingMenu')
AddEventHandler('yp_crafting:startCraftingMenu', function(prints)
	local elements = prints
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'crafting_menu', {
		title = 'Crafting',
		align = 'bottom-right',
		elements = elements},
		function(data,menu)
			TriggerEvent('yp_crafting:choseItem', data.current.value)
		end,
		function(data,menu)
			menu.close()
		end)
end)

RegisterNetEvent('yp_crafting:choseItem')
AddEventHandler('yp_crafting:choseItem', function(printName)
	local elements = {}
	for i, v in ipairs(recipes) do
		if v.blueprint == printName then
			table.insert(elements, {label = v.label, value = v.value, recipe = v.recipe})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'crafting_menu2',{
		title = 'Crafting',
		align = 'bottom-right',
		elements = elements},
		function(data, menu)
			menu.close()
			TriggerServerEvent('yp_crafting:craftItem', data.current.value, data.current.recipe)
		end,
		function(data, menu)
			menu.close()
		end)
end)

RegisterNetEvent('yp_crafting:openResearchMenu')
AddEventHandler('yp_crafting:openResearchMenu', function(data)
	local elements = data
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'research_menu', {
		title = 'Research',
		align = 'bottom-right',
		elements = elements
	},
	function(data, menu)
		local action = data.current.value
		Citizen.CreateThread(function()
			menu.close()
			researched = true
			exports['progressBars']:startUI(15000, 'Researching')
			Citizen.Wait(15000)
			TriggerServerEvent('yp_base:addItem', action, 1)
		end)
		

	end,
	function(data, menu)
		menu.close()
	end)
end)

--Main Thread
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		if Vdist(pos.x, pos.y, pos.z, 2328.0285, 2571.2680, 46.6769) < 3 then
			exports['yp_base']:DisplayHelpText("Press ~INPUT_CONTEXT~ to craft")
			if IsControlJustPressed(0,51) then
				TriggerServerEvent('yp_crafting:getInvData')
			end
		elseif Vdist(pos.x, pos.y, pos.z, 1272.7113, -1711.6768, 54.7714) < 3 then
			exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to research')
			if IsControlJustPressed(0,51) then
				if not researched then
					TriggerServerEvent('yp_crafting:getResearch')
				else
					exports['mythic_notify']:DoHudText('inform', 'You are too tired to research right now.')
				end
			end
		end
		Citizen.Wait(0)
	end
end)