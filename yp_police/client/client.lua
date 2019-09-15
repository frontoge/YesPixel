local playerReady = false
--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

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
					--Viewid code
				elseif action2 == 'search' then
					--Search code
				elseif action2 == 'escort' then
					local closestPlayer, distance = ESX.Game.GetClosestPlayer()
					if closestPlayer ~= -1 and distance < 3.0 then
						TriggerServerEvent('yp_police:escort', GetPlayerServerId(closestPlayer))
					end
				elseif action2 == 'putveh' then
					--Put player in vehicle
				elseif action2 == 'pullveh' then
					--Pull from vehicle
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
					{label = 'Search Glovebox', value = 'search_glovebox'}
				}},
			function(data2, menu2)
				local action2 = data2.current.value
				if action2 == 'registration' then
					--Registration Code

				elseif action2 == 'impound' then

				elseif action2 == 'search_trunk' then

				else

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

--Events
RegisterNetEvent('yp_police:playerReady')
AddEventHandler('yp_police:playerReady', function()
	playerReady = true
end)

RegisterNetEvent('yp_police:openJobMenu')
AddEventHandler('yp_police:openJobMenu', function()
	openJobMenu()
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
		if Vdist(pos.x, pos.y, pos.z, 477.8778, -984.2165, 24.9147) < 20 then --Evidence Locker
			DrawMarker(1, 477.8778, -984.2165, 23.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if Vdist(pos.x, pos.y, pos.z, 452.0335, -980.3474, 30.6896) < 20 then -- Armory
			DrawMarker(1, 452.0335, -980.3474, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		if Vdist(pos.x, pos.y, pos.z, 451.0890, -992.4544, 30.6896) < 20 then
			DrawMarker(1, 451.0890, -992.4544, 29.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
		end

		--Listners

		if IsControlJustPressed(0, 167) then
			TriggerServerEvent('yp_police:startJobMenu')
		end

		if Vdist(pos.x, pos.y, pos.z, 477.8778, -984.2165, 24.9147) < 1 then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to access Deposit Evidence")
			if IsControlJustPressed(0,51) then
				--Open Evidence Locker
			end
		elseif Vdist(pos.x, pos.y, pos.z, 452.0335, -980.3474, 30.6896) < 1 then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to access the Armory")
			if IsControlJustPressed(0,51) then
				--Open Armory
			end
		elseif Vdist(pos.x, pos.y, pos.z, 451.0890, -992.4544, 30.6896) < 1 then
			DisplayHelpText("Press ~INPUT_CONTEXT~ to change your outfit")
			if IsControlJustPressed(0,51) then
				--Open Locker rooms
			end
		end

		Citizen.Wait(0)
	end
end)
