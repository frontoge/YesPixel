--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--Config Locals
local cuffsToSearch = true
local useKey = 47
local engineKey = 303 -- Key to start engine

--Script Locals
local isDead = false
local isCuffed = false
local keys = {}
local dragStatus = {}


dragStatus.isDragged = false

--ESX init
ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

AddEventHandler('playerSpawned', function(spawn)
  isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  isDead = true
end)

--Events
RegisterNetEvent('showmyid')
AddEventHandler('showmyid', function(data)
  if data.sex == 'm' then
    data.sex = 'Male'
  else
    data.sex = 'Female'
  end
  
  exports['mythic_notify']:DoLongHudText('inform', 'Name: ' .. data.firstname .. ' ' .. data.lastname)
  exports['mythic_notify']:DoLongHudText('inform',  'DOB: ' .. data.dob)
  exports['mythic_notify']:DoLongHudText('inform', 'Sex: ' .. data.sex)
  exports['mythic_notify']:DoLongHudText('inform', 'Height: ' .. data.height .. 'cm')
end)


RegisterNetEvent('startid')
AddEventHandler('startid', function()
  
  TriggerServerEvent('getplayerdata')
  
end)

RegisterNetEvent('toggledoor')
AddEventHandler('toggledoor', function(doornumber)
    local vehicle = ESX.Game.GetClosestVehicle()
    toggleDoor(vehicle, doornumber)
    
end)

RegisterNetEvent('yp_userinteraction:lockpickvehicle')
AddEventHandler('yp_userinteraction:lockpickvehicle', function()
    local vehicle = ESX.Game.GetVehicleInDirection()
      if DoesEntityExist(vehicle) then
        local playerPed = GetPlayerPed(-1)
        TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
        Citizen.Wait(15000)
        ClearPedTasksImmediately(playerPed)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        exports['mythic_notify']:DoHudText('success', 'Vehicle Unlocked')
      else
        exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
      end
end)

RegisterNetEvent('userinteraction:windowcommand')
AddEventHandler('userinteraction:windowcommand', function(windowNum, state)
  if IsPedInAnyVehicle(GetPlayerPed(-1)) then
    local vehicle = ESX.Game.GetClosestVehicle()
    toggleWindow(vehicle, windowNum, state)
  else
    exports['mythic_notify']:DoHudText('error', 'Not in a Vehicle')
  end
    
end)

RegisterNetEvent('yp_userinteraction:getcuffed')
AddEventHandler('yp_userinteraction:getcuffed', function()
  isCuffed = true
  local playerPed = PlayerPedId()
  RequestAnimDict('mp_arresting')
  while not HasAnimDictLoaded('mp_arresting') do
    Citizen.Wait(100)
  end

  TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

  SetEnableHandcuffs(playerPed, true)
  DisablePlayerFiring(playerPed, true)
  SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
  SetPedCanPlayGestureAnims(playerPed, false)
  FreezeEntityPosition(playerPed, true)
  DisplayRadar(false)

end)

RegisterNetEvent('yp_userinteraction:getuncuffed')
AddEventHandler('yp_userinteraction:getuncuffed', function()
  isCuffed = false
  local playerPed = PlayerPedId()
  ClearPedSecondaryTask(playerPed)
  SetEnableHandcuffs(playerPed, false)
  DisablePlayerFiring(playerPed, false)
  SetPedCanPlayGestureAnims(playerPed, true)
  FreezeEntityPosition(playerPed, false)
  DisplayRadar(true)
end)

RegisterNetEvent('yp_userinteraction:escort')
AddEventHandler('yp_userinteraction:escort', function(dragger)
	if not isCuffed then
		return
	end

	dragStatus.isDragged = not dragStatus.isDragged
	dragStatus.Dragger = dragger
end)

RegisterNetEvent('putInVehicle')
AddEventHandler('putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if not isCuffed then
		return
	end

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				dragStatus.isDragged = false
			end
		end
	end
end)

RegisterNetEvent('pullOutVehicle')
AddEventHandler('pullOutVehicle', function()
	local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)

RegisterNetEvent('showPlayerInventory')
AddEventHandler('showPlayerInventory', function(target, targetInv)
  local elements = {}
  local inventory = targetInv.inventory
  local weapons = targetInv.weapons
  local accounts = targetInv.accounts
  
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
  
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_inventory', {
      label = 'Player Inventory',
      align = 'bottom-right',
      elements = elements},
    function(data, menu)
      TriggerServerEvent('takePlayerItem', data.current.value, data.current.amount, data.current.itemType, target)
      TriggerServerEvent('yp_userinteraction:getPlayerInventory', target)
    end,
    function(data, menu)
      menu.close()
    end)
end)




--Functions
function toggleDoor (vehicle, doornumber)
  
  local isopen = GetVehicleDoorAngleRatio(vehicle, doornumber)
  if (isopen == 0) then
    SetVehicleDoorOpen(vehicle, doornumber , 0, 0)
  else
    SetVehicleDoorShut(vehicle, doornumber ,0)
  end
end

function checkForKeys(vehicle)
  local found = false
    for _, v in ipairs(keys) do
      if v == vehicle then
        found = true
      end
    end
    return found
end

function toggleWindow(vehicle, window, state)
    if state then
      RollUpWindow(vehicle, window)
    else
      RollDownWindow(vehicle, window)
    end
end

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('getOtherPlayerData', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = _U('search'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function inspectVehicle(vehicle)
  local body = GetVehicleBodyHealth(vehicle) / 10.0
  local engine = GetVehicleEngineHealth(vehicle) / 10.0
  local oil = GetVehicleOilLevel(vehicle)
  local fuelTank = GetVehiclePetrolTankHealth(vehicle) / 10.0


  
  exports['mythic_notify']:DoLongHudText('inform', ('Engine: %' .. engine))
  exports['mythic_notify']:DoLongHudText('inform', ('body: %' .. body))
  exports['mythic_notify']:DoLongHudText('inform', ('Oil Level: ' .. oil .. "/5.0"))
  exports['mythic_notify']:DoLongHudText('inform', ('Fuel Tank Health: %' .. tostring(fuelTank)))
end



function OpenInteractionMenu()
  ESX.UI.Menu.CloseAll()
  
  
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_actions', {--Create Main User interaction menu
    title = 'Interactions',
    align = 'bottom-right',
    elements = {{label = 'Players', value = 'player_menu'},
    {label = 'Vehicles', value = 'vehicle_menu'}
    }},
    function(data,menu)
      if data.current.value == 'player_menu' then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_menu', {--Create Player interaction Menu
            title = 'Players Menu',
            align = 'bottom-right',
            elements = {{label = 'View My ID', value = 'view_id'},
              --{label = 'View My Bills', value = 'view_bills'},
              {label = 'Cuff', value = 'cuff'},
              {label = 'Uncuff', value = 'uncuff'},
              {label = 'Escort', value = 'escort'},
              {label = 'Put in Veh', value = 'put_vehicle'},
              {label = 'Drag From Veh', value = 'pull_vehicle'},
              {label = 'Search', value = 'search'}
            }},
          function (data2, menu2)
            local action2 = data2.current.value
            if action2 == 'view_id' then
              menu2.close()
              TriggerServerEvent('getplayerdata') --Get player data of the current user
              
            --elseif action2 == 'viewbills' then
              
            elseif action2 == 'cuff' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 1 then
                TriggerServerEvent('cuff', GetPlayerServerId(closestPlayer))
              else
                exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
              end
              
            elseif action2 == 'uncuff' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 1 then
                TriggerServerEvent('uncuff', GetPlayerServerId(closestPlayer))
              else
                exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
              end
              
            elseif action2 == 'escort' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 2 then
                TriggerServerEvent('escort', GetPlayerServerId(closestPlayer))
              else
                exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
              end
              
            elseif action2 == 'put_vehicle' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 2 then
                TriggerServerEvent('yp_userinteraction:putInVehicle', GetPlayerServerId(closestPlayer))
              end
            elseif action2 == 'pull_vehicle' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 2 then
                TriggerServerEvent('yp_userinteraction:pullOutVehicle', GetPlayerServerId(closestPlayer))
              end
            elseif action2 == 'search' then
              local closestPlayer, distance = ESX.Game.GetClosestPlayer()
              if closestPlayer ~= -1 and distance <= 3 then
                if cuffsToSearch then
                  if IsPedCuffed(GetPlayerPed(closestPlayer)) then
                    TriggerServerEvent('yp_userinteraction:getPlayerInventory', closestPlayer)
                  else
                    exports['mythic_notify']:DoHudText('error', 'Player not Cuffed!')
                  end
                else
                  TriggerServerEvent('yp_userinteraction:getPlayerInventory', closestPlayer)
                end
              else
                exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
              end
            end
          end,
          function (data2, menu2)
            menu2.close()
          end)
        
        
      elseif data.current.value == 'vehicle_menu' then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {--Create Vehicle Interaction Menu
            title = 'Vehicles Menu',
            align = 'bottom-right',
            elements = {{label = 'Grab Keys', value = 'grab_keys'},
              {label = 'Lock Vehicle', value = 'lock_vehicle'},
              {label = 'Unlock Vehicle', value = 'unlock_vehicle'},
              {label = 'Lockpick Vehicle', value = 'lockpick'},
              {label = 'Open/Close Hood', value = 'open_hood'},
              {label = 'Open/Close Trunk', value = 'open_trunk'},
              {label = 'Doors', value = 'door_menu'},
              {label = 'Windows Up', value = 'windowup_menu'},
              {label = 'Windows Down', value = 'windowdown_menu'},
              {label = 'Toggle Engine', value = 'toggle_engine'},
              {label = 'Inspect Vehicle', value = 'inspect_vehicle'}
              }},
            function (data2, menu2)
              local action2 = data2.current.value
              
              if action2 == 'grab_keys' then
                local keysfound = false
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  local vehicle = ESX.Game.GetClosestVehicle()
                  keysfound = checkForKeys(vehicle)
                  if not keysfound then
                    table.insert(keys, vehicle)
                    exports['mythic_notify']:DoHudText('inform', 'You grabbed the keys')
                  else
                    exports['mythic_notify']:DoHudText('error', 'You already have the keys!')
                  end
                else
                  exports['mythic_notify']:DoHudText('error', 'You are not in a Vehicle!')
                end
                  
              elseif action2 == 'lock_vehicle' then--Lock Vehicle Option SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = ESX.Game.GetClosestVehicle()
                  menu2.close()
                  SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                  exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
                elseif DoesEntityExist(vehicle) then
                  if checkForKeys(vehicle) then
                    menu2.close()
                    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                    exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
                  else
                    exports['mythic_notify']:DoHudText('error', 'No Keys!')
                  end
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end

              elseif action2 == 'unlock_vehicle' then--Unlock Vehicle Option
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = ESX.Game.GetClosestVehicle()
                  menu2.close()
                  SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                  exports['mythic_notify']:DoHudText('inform', 'Doors Unlocked')
                elseif DoesEntityExist(vehicle) then
                  if checkForKeys(vehicle) then
                    menu2.close()
                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    exports['mythic_notify']:DoHudText('inform', 'Doors Unlocked')
                  else
                    exports['mythic_notify']:DoHudText('error', 'No Keys!')
                  end
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end
              
              elseif action2 == 'lockpick' then
                TriggerServerEvent('checkforpick')
                
              elseif action2 == 'open_hood' then
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = ESX.Game.GetClosestVehicle()
                  menu2.close()
                  toggleDoor(vehicle, 4)
                elseif DoesEntityExist(vehicle) then
                  menu2.close()
                  toggleDoor(vehicle, 4)
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end
                
              elseif action2 == 'open_trunk' then
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = ESX.Game.GetClosestVehicle()
                  menu2.close()
                  toggleDoor(vehicle, 5)
                elseif DoesEntityExist(vehicle) then
                  menu2.close()
                  toggleDoor(vehicle, 5)
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end
                
              elseif action2 == 'door_menu' then
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'door_menu', {
                      title = 'Doors',
                      align = 'bottom-right',
                      elements = {{label = 'Door 1', value = 'door1'},
                        {label = 'Door 2', value = 'door2'},
                        {label = 'Door 3', value = 'door3'},
                        {label = 'Door 4', value = 'door4'}
                      }},
                    function(data3,menu3)
                      local action3 = data3.current.value
                      if action3 == 'door1' then
                        menu3.close()
                        local vehicle = ESX.Game.GetClosestVehicle()
                        toggleDoor(vehicle, 0)
                      elseif action3 == 'door2' then
                        menu3.close()
                        local vehicle = ESX.Game.GetClosestVehicle()
                        toggleDoor(vehicle, 1)
                        
                      elseif action3 == 'door3' then
                        menu3.close()
                        local vehicle = ESX.Game.GetClosestVehicle()
                        toggleDoor(vehicle, 2)
                        
                      elseif action3 == 'door4' then
                        menu3.close()
                        local vehicle = ESX.Game.GetClosestVehicle()
                        toggleDoor(vehicle, 3)
                      end
                    end,
                    function(data3, menu3)
                      menu3.close()
                    end)
                else
                  exports['mythic_notify']:DoLongHudText('error', 'Not in a Vehicle!')
                end
              elseif action2 == 'windowup_menu' then
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'windowup_menu', {
                    title = 'Windows',
                    align = 'bottom-right',
                    elements = {{label = 'Window 1', value = 'window1'},
                      {label = 'Window 2', value = 'window2'},
                      {label = 'Window 3', value = 'window3'},
                      {label = 'Window 4', value = 'window4'}
                    }},
                  function(data3,menu3)
                    local action3 = data3.current.value
                    local vehicle = ESX.Game.GetClosestVehicle()
                    if action3 == 'window1' then
                      menu3.close()
                      toggleWindow(vehicle, 0, true)
                      
                    elseif action3 == 'window2' then
                      menu3.close()
                      toggleWindow(vehicle, 1, true)
                      
                    elseif action3 == 'window3' then
                      menu3.close()
                      toggleWindow(vehicle, 2, true)
                      
                    elseif action3 == 'window4' then
                      menu3.close()
                      toggleWindow(vehicle, 3, true)
                    end
                  end,
                  function(data3, menu3)
                    menu3.close()
                  end)
                else
                  exports['mythic_notify']:DoLongHudText('error', 'Not in a Vehicle!')
                end
              elseif action2 == 'windowdown_menu' then
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'windowdown_menu', {
                    title = 'Windows',
                    align = 'bottom-right',
                    elements = {{label = 'Window 1', value = 'window1'},
                      {label = 'Window 2', value = 'window2'},
                      {label = 'Window 3', value = 'window3'},
                      {label = 'Window 4', value = 'window4'}
                    }},
                  function(data3,menu3)
                    local action3 = data3.current.value
                    local vehicle = ESX.Game.GetClosestVehicle()
                    if action3 == 'window1' then
                      menu3.close()
                      toggleWindow(vehicle, 0, false)
                      
                    elseif action3 == 'window2' then
                      menu3.close()
                      toggleWindow(vehicle, 1, false)
                      
                    elseif action3 == 'window3' then
                      menu3.close()
                      toggleWindow(vehicle, 2, false)
                      
                    elseif action3 == 'window4' then
                      menu3.close()
                      toggleWindow(vehicle, 3, false)
                    end
                  end,
                  function(data3, menu3)
                    menu3.close()
                  end)
                else
                  exports['mythic_notify']:DoLongHudText('error', 'Not in a Vehicle!')
                end
                
              elseif action2 == 'toggle_engine' then
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  local vehicle = ESX.Game.GetClosestVehicle()
                  if GetIsVehicleEngineRunning(vehicle) then
                    SetVehicleEngineOn(vehicle, false, false, true)
                  else
                    SetVehicleEngineOn(vehicle, true, false)
                  end
                else
                  exports['mythic_notify']:DoHudText('error', 'Not in a Vehicle!')
                end
                
              elseif action2 == 'inspect_vehicle' then
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = ESX.Game.GetClosestVehicle()
                end
                if DoesEntityExist(vehicle) then
                  menu2.close()
                  inspectVehicle(vehicle)
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end
              end
            end,
            
            function (data2, menu2)
              menu2.close()
            end)
      end
    end,    
    function(data,menu)
      menu.close()
    end)
end

--Threads
Citizen.CreateThread(function()
	local playerPed
	local targetPed

	while true do
		Citizen.Wait(1)

		if isCuffed then
			playerPed = PlayerPedId()

			if dragStatus.isDragged then
				targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.Dragger))

				-- undrag if target is in an vehicle
				if not IsPedSittingInAnyVehicle(targetPed) then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				else
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

				if IsPedDeadOrDying(targetPed, true) then
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

			else
				DetachEntity(playerPed, true, false)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

--Handcuff Thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if isCuffed then
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)



--Main Thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
      
    if IsControlJustReleased(0, useKey) and not isDead and not isCuffed then
      OpenInteractionMenu()
    end
    --[[if IsControlJustReleased(0, engineKey) then
      local ped = GetPlayerPed(-1)
      if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(vehicle, -1) == ped then
          Citizen.Wait(500)
          if GetIsVehicleEngineRunning(vehicle) then
            SetVehicleEngineOn(vehicle, false, false, true)
          else
            SetVehicleEngineOn(vehicle, true, false)
          end
        end
      end
    end]]
  end
end)
