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

local blackListKeys = {}

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

function isKeyBlacklisted(plate)
  for i, v in ipairs(blackListKeys) do
    if v == plate then return true end
  end
  return false
end

function playLockAnim(vehicle)
  Citizen.CreateThread(function()
    RequestAnimDict('anim@mp_player_intmenu@key_fob@')
    while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do 
      Citizen.Wait(0)
    end
    TaskPlayAnim(GetPlayerPed(-1), 'anim@mp_player_intmenu@key_fob@', "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
  end)
end

function OpenBodySearchMenu(player)
  TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(player), GetPlayerName(player))
end

--Radial Menu
RegisterCommand("search", function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local target, distance = ESX.Game.GetClosestPlayer()
    if distance > 1.5 then return end
    --local dist = Vdist(target.x, target.y, target.z, pos, pos, pos)
    RequestAnimDict('combat@aim_variations@arrest')
    while not HasAnimDictLoaded('combat@aim_variations@arrest') do
      Citizen.Wait(0)
    end
    TaskPlayAnim(GetPlayerPed(-1), 'combat@aim_variations@arrest', 'cop_med_arrest_01', 8.0, -8,3750, 2, 0, 0, 0, 0)
    exports['yp_progressbar']:startBar({{"Searching", 4500}}, nil, nil, 1, nil) 
    Citizen.Wait(5000)
    OpenBodySearchMenu(target)
end)

RegisterCommand('flipvehicle', function(source, args)
  local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
  if IsPedInAnyVehicle(GetPlayerPed(-1)) then
    vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
  end
  if DoesEntityExist(vehicle) then
    menu2.close()
    inspectVehicle(vehicle)
  else
    exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
  end
end)

RegisterCommand('cuff', function(source, args)
  local closestPlayer, distance = ESX.Game.GetClosestPlayer()
  if closestPlayer ~= -1 and distance <= 1 then
    TriggerServerEvent('cuff', GetPlayerServerId(closestPlayer))
  else
    exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
  end
end)

RegisterCommand('uncuff', function(source, args)
  local closestPlayer, distance = ESX.Game.GetClosestPlayer()
  if closestPlayer ~= -1 and distance <= 1 then

    TriggerServerEvent('uncuff', GetPlayerServerId(closestPlayer))
  else
    exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
  end
end)

RegisterCommand('dragout', function(source, args)
  local closestPlayer, distance = ESX.Game.GetClosestPlayer()
  if closestPlayer ~= -1 and distance <= 2 then
    TriggerServerEvent('yp_userinteraction:pullOutVehicle', GetPlayerServerId(closestPlayer))
  end
end)

RegisterCommand('putinveh', function(source, args)
  local closestPlayer, distance = ESX.Game.GetClosestPlayer()
  if closestPlayer ~= -1 and distance <= 2 then
    TriggerServerEvent('yp_userinteraction:putInVehicle', GetPlayerServerId(closestPlayer))
  end
end)

RegisterCommand('viewid', function(source, args)
  TriggerServerEvent('getplayerdata')
end)

RegisterCommand('escort', function(source, args)
  local closestPlayer, distance = ESX.Game.GetClosestPlayer()
  if closestPlayer ~= -1 and distance <= 2 then
    TriggerServerEvent('escort', GetPlayerServerId(closestPlayer))
  else
    exports['mythic_notify']:DoHudText('error', 'No Players Nearby!')
  end
end)

RegisterCommand('inspect', function(source, args)
  local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
  if IsPedInAnyVehicle(GetPlayerPed(-1)) then
    vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
  end
  if DoesEntityExist(vehicle) then
    inspectVehicle(vehicle)
  else
    exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
  end
end)

RegisterCommand('lockpick', function(source, args)
  TriggerServerEvent('checkforpick')
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
    local vehicle = nil
    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
      vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
    else
      vehicle = ESX.Game.GetVehicleInDirection()
    end
    if DoesEntityExist(vehicle) then
      toggleDoor(vehicle, doornumber)
    end    
end)

RegisterNetEvent('yp_userinteraction:lockpickvehicle')
AddEventHandler('yp_userinteraction:lockpickvehicle', function()
  if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
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
  else 
    Citizen.CreateThread(function()
      local count = 0
      while count < 3 do
        local timer = math.random(10000, 20000)
        exports['progressBars']:startUI(timer, "Stage " .. count + 1)
        Citizen.Wait(timer)
        count = count + 1
        Citizen.Wait(300)
      end
      
      local chance = math.random(0, 100)
      if chance < 20 then
        TriggerServerEvent('yp_userinteraction:consumePick')
        exports['mythic_notify']:DoHudText('error', 'Hotwire failed!', 3000)
      else
        exports['mythic_notify']:DoHudText('inform', 'Vehicle Started!', 3000)
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1)))
        exports['EngineToggle']:addKey(plate)
        TriggerEvent('EngineToggle:Engine')
      end
    end)
  end
end)

RegisterNetEvent('userinteraction:windowcommand')
AddEventHandler('userinteraction:windowcommand', function(windowNum, state)
  if IsPedInAnyVehicle(GetPlayerPed(-1)) then
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
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
	if not isCuffed and not IsPedDeadOrDying(GetPlayerPed(-1), true) then
		return
	end

	dragStatus.isDragged = not dragStatus.isDragged
	dragStatus.Dragger = dragger
end)

RegisterNetEvent('putInVehicle')
AddEventHandler('putInVehicle', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
      for i = 2, 0, -1 do
        
        if not IsVehicleSeatFree(i) then
          SetPedIntoVehicle(playerPed, vehicle, i)
          return
        end
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

RegisterNetEvent('yp_userinteraction:showPlayerInventory')
AddEventHandler('yp_userinteraction:showPlayerInventory', function(target, targetInv)
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
               --Get player data of the current user
              
            --elseif action2 == 'viewbills' then
              
            elseif action2 == 'cuff' then
              
              
            elseif action2 == 'uncuff' then
              
              
            elseif action2 == 'escort' then
              
              
            elseif action2 == 'put_vehicle' then
              
            elseif action2 == 'pull_vehicle' then
              
            elseif action2 == 'search' then
    
            end
          end,
          function (data2, menu2)
            menu2.close()
          end)
        
        
      elseif data.current.value == 'vehicle_menu' then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {--Create Vehicle Interaction Menu
            title = 'Vehicles Menu',
            align = 'bottom-right',
            elements = {
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
              
              if action2 == 'lock_vehicle' then--Lock Vehicle Option SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
                  menu2.close()
                  SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                  exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
                  playLockAnim()
                elseif DoesEntityExist(vehicle) then
                  if checkForKeys(vehicle) then
                    menu2.close()
                    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                    exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
                    playLockAnim()
                  else
                    exports['mythic_notify']:DoHudText('error', 'No Keys!')
                  end
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end

              elseif action2 == 'unlock_vehicle' then--Unlock Vehicle Option
                local vehicle = ESX.Game.GetVehicleInDirection()
                if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                  vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
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
                  vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
                  menu2.close()
                  toggleDoor(vehicle, 4)
                elseif DoesEntityExist(vehicle) then
                  menu2.close()
                  toggleDoor(vehicle, 4)
                else
                  exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
                end
                
              elseif action2 == 'open_trunk' then
                
              elseif action2 == 'door_menu' then
                
              elseif action2 == 'windowup_menu' then
                
              elseif action2 == 'windowdown_menu' then
                
                
              elseif action2 == 'toggle_engine' then
                
              elseif action2 == 'inspect_vehicle' then
                
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

		if isCuffed or IsPedDeadOrDying(GetPlayerPed(-1)) then
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
      DisableControlAction(0, 137, true) -- Job


			DisableControlAction(0, 73, true) -- Disable clearing animation

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
      --OpenInteractionMenu()
    end

    if IsControlJustReleased(0, 301) then --If M is pressed
      local vehicle = ESX.Game.GetClosestVehicle() --Get Vehicle
      if IsPedInAnyVehicle(GetPlayerPed(-1)) then
        vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
        local plate = GetVehicleNumberPlateText(vehicle)
        if not exports['EngineToggle']:hasKey(plate) and not isKeyBlacklisted(plate) then -- If you dont have the keys and you havent already tried to grab them
          local num = math.random(0, 100)
          if num < 15 then -- 15% chance of finding keys in the car
            exports['mythic_notify']:DoHudText('inform', 'You grabbed the keys')
            exports['EngineToggle']:addKey(plate) --Give the keys
          else
            exports['mythic_notify']:DoHudText('error', 'You were unable to find the keys')
            table.insert(blackListKeys, plate)
          end
        elseif exports['EngineToggle']:hasKey(plate) then--If you have the keys already
          if GetVehicleDoorsLockedForPlayer(vehicle, GetPlayerPed(-1)) then --If the doors are locked
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            exports['mythic_notify']:DoHudText('inform', 'Doors unlocked')
            --playLockAnim(vehicle)
            PlayVehicleDoorOpenSound(vehicle, 0)
          else
            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
            exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
            PlayVehicleDoorCloseSound(vehicle, 1)
            --playLockAnim(vehicle)
          end
        end
      elseif DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        if exports['EngineToggle']:hasKey(plate) then
          if GetVehicleDoorsLockedForPlayer(vehicle, GetPlayerPed(-1)) then
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            exports['mythic_notify']:DoHudText('inform', 'Doors unlocked')
            playLockAnim(vehicle)
            PlayVehicleDoorOpenSound(vehicle, 0)
            
          else
            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
            exports['mythic_notify']:DoHudText('inform', 'Doors Locked')
            playLockAnim(vehicle)
            PlayVehicleDoorCloseSound(vehicle, 1)
            SoundVehicleHornThisFrame(vehicle)
          end
        else
          exports['mythic_notify']:DoHudText('error', 'No Keys!')
        end
      else
        exports['mythic_notify']:DoHudText('error', 'No Vehicle Nearby!')
      end
    end
  end

end)
