--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local playerReady = false
local blipRobbery
local listening = false
local pressed = false
local banks = {
  { name = 'Flecca Legion Square', x = 146.6339, y = -1045.9384, z = 29.3680, hacked = false, exit = {x = 150.8418, y= -1037.4572, z=29.3724}, vault = 'v_ilev_gb_vauldr', doorS = -110.134025, drill = {}},  
  { name = 'Flecca Del Perro', x = -1210.7067, y = -336.5490, z = 37.7810, hacked = false, exit = {x = -1214.3476, y= -327.8316, z= 37.7779}, vault = 'v_ilev_gb_vauldr', doorS = -63.136264, drill ={}},
  { name = 'Flecca Great Ocean Hwy', x = -2956.5825, y = 481.7070, z = 15.6970, hacked = false, exit = {x = -2965.7917, y= 482.9926, z= 15.6971}, vault = 'hei_prop_heist_sec_door', doorS = -2.459748, drill = {}},
  { name = 'Blaine County Savings', x = -105.4070, y = 6471.8227 , z = 31.6267, hacked = false, exit = {x = -110.7807, y= 6462.9052, z= 31.6407}, vault = 'v_ilev_cbankvauldoor01', doorS = 47.0, drill={}},
  { name = 'Flecca Sandy Shores', x = 1176.0827, y = 2712.8020, z = 38.0880, hacked = false, exit = {x = 1175.2392, y= 2703.5493, z= 38.1727}, vault = 'v_ilev_gb_vauldr', doorS = 90.0, drill = {}},
  { name = 'Flecca Vinewood', x = -353.8114, y = -55.1726, z = 49.0365, hacked = false, exit = {x = -350.0368, y= -46.7347, z= 49.0368}, vault = 'v_ilev_gb_vauldr', doorS = -110.134025, drill = {}},
  { name = 'Flecca Hawic Ave', x = 311.2101, y = -284.4296, z = 54.1648, hacked = false, exit = {x = 315.2653, y= -275.9373, z= 54.1632}, vault = 'v_ilev_gb_vauldr', doorS = -110.134025, drill = {}}}--Sweedbank Exit 1 231.5328 215.1501 106.2800 Exit 2 259.3374 203.4905 106.2801
  table.insert(banks[1].drill, {x = 149.8671, y = -1044.8991, z = 29.3462, drilled = false})
  table.insert(banks[1].drill, {x = 151.2031, y = -1046.6319, z = 29.3463, drilled = false})
  table.insert(banks[1].drill, {x = 150.2059, y = -1049.9116, z = 29.3463, drilled = false})
  table.insert(banks[1].drill, {x = 148.0631, y = -1050.7391, z = 29.3463, drilled = false})
  table.insert(banks[1].drill, {x = 146.7989, y = -1048.4805, z = 29.3463, drilled = false})
  
  table.insert(banks[2].drill, {x = -1209.7980, y = -333.7249, z = 37.7592, drilled = false})
  table.insert(banks[2].drill, {x = -1207.4561, y = -333.7505, z = 37.7592, drilled = false})
  table.insert(banks[2].drill, {x = -1207.5247, y = -336.5192, z = 37.7593, drilled = false})
  table.insert(banks[2].drill, {x = -1206.4595, y = -338.7965, z = 37.7593, drilled = false})
  table.insert(banks[2].drill, {x = -1208.9548, y = -338.3133, z = 37.7592, drilled = false})
  
  table.insert(banks[3].drill, {x = -2958.4799, y = 483.9898, z = 15.6752, drilled = false})
  table.insert(banks[3].drill, {x = -2957.5324, y = 485.8226, z = 15.6753, drilled = false})
  table.insert(banks[3].drill, {x = -2954.1328, y = 486.3158, z = 15.6754, drilled = false})
  table.insert(banks[3].drill, {x = -2952.5925, y = 484.2815, z = 15.6753, drilled = false})
  table.insert(banks[3].drill, {x = -2954.0415, y = 482.4615, z = 15.6753, drilled = false})
  
  table.insert(banks[4].drill, {x = -107.1649, y = 6473.5209, z = 31.6267, drilled = false})
  table.insert(banks[4].drill, {x = -107.6142, y = 6475.7397, z = 31.6267, drilled = false})
  table.insert(banks[4].drill, {x = -105.9026, y = 6478.6689, z = 31.6267, drilled = false})
  table.insert(banks[4].drill, {x = -103.2024, y = 6478.1918, z = 31.6267, drilled = false})
  table.insert(banks[4].drill, {x = -102.9210, y = 6475.4882, z = 31.6267, drilled = false})
  
  table.insert(banks[5].drill, {x = 1173.7408, y = 2710.7224, z = 38.0662, drilled = false})
  table.insert(banks[5].drill, {x = 1171.7821, y = 2711.9296, z = 38.0662, drilled = false})
  table.insert(banks[5].drill, {x = 1171.3123, y = 2715.3281, z = 38.0663, drilled = false})
  table.insert(banks[5].drill, {x = 1173.3037, y = 2716.7441, z = 38.0663, drilled = false})
  table.insert(banks[5].drill, {x = 1175.1782, y = 2715.0104, z = 38.0662, drilled = false})
  
  table.insert(banks[6].drill, {x = -350.9709, y = -54.0551, z = 49.0148, drilled = false})
  table.insert(banks[6].drill, {x = -349.5157, y = -55.7606, z = 49.0148, drilled = false})
  table.insert(banks[6].drill, {x = -350.1953, y = -59.1343, z = 49.0148, drilled = false})
  table.insert(banks[6].drill, {x = -352.4359, y = -60.0035, z = 49.0148, drilled = false})
  table.insert(banks[6].drill, {x = -353.8075, y = -57.7657, z = 49.0148, drilled = false})
  
  table.insert(banks[7].drill, {x = 314.1428, y = -283.3122, z = 54.1430, drilled = false})
  table.insert(banks[7].drill, {x = 315.5412, y = -284.9682, z = 54.1430, drilled = false})
  table.insert(banks[7].drill, {x = 314.9196, y = -288.2956, z = 54.1430, drilled = false})
  table.insert(banks[7].drill, {x = 312.3575, y = -289.1061, z = 54.1430, drilled = false})
  table.insert(banks[7].drill, {x = 311.1881, y = -286.8614, z = 54.1430, drilled = false})
 
 local buttons = {
  {char = 'Z', value = 20}, {char = 'F', value = 49}, {char = 'B', value = 29}, {char = 'H', value = 304}, {char = 'Space', value = 179}, {char = 'K', value = 311},
  {char = 'L', value = 7}, {char = 'M', value = 244}, {char = 'N', value = 306}, {char = 'U', value = 303}, {char = 'Y', value = 246}, {char = 'LShift', value = 21}}

--ESX INIT
local ESX = nil

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

function listenForPress(key)
  Citizen.CreateThread(function()
    while listening do
      if IsControlJustPressed(1, key) then
        pressed = true
      end
      Citizen.Wait(0)
    end
  end)
end

function resetDoor(bankNum)
  local bank = banks[bankNum]
  local door = GetClosestObjectOfType(bank.x, bank.y, bank.z, 3.0, bank.vault)
  FreezeEntityPosition(door, false)
  SetEntityRotation(door, 0.0, 0.0, bank.doorS)
  FreezeEntityPosition(door, true)
end

function openDoor(bankNum)
  resetDoor(bankNum)
  bank = banks[bankNum]
  local door = GetClosestObjectOfType(bank.x, bank.y, bank.z, 3.0, bank.vault)
  local rotation = GetEntityRotation(door)["z"]
  local x = 0
  Citizen.CreateThread(function()
    FreezeEntityPosition(door, false)
    while x < 400 do
      if bank.name ~= 'Blaine County Savings' then
        rotation = rotation - 0.25
      else
        rotation = rotation + 0.25
      end
      SetEntityRotation(door, 0.0, 0.0, rotation)
      x = x + 1
      Citizen.Wait(0)
    end
    FreezeEntityPosition(door, true)
  end)
end

--Register Events
RegisterNetEvent('yp_bankrob:playerReady')
AddEventHandler('yp_bankrob:playerReady', function()
  playerReady = true
  for i = 1, #banks, 1 do
    resetDoor(i)
  end
end)

RegisterNetEvent('yp_bankrob:startHack')
AddEventHandler('yp_bankrob:startHack', function(bank)
  exports['mythic_notify']:DoHudText('inform', 'Hacking starting')
  local failed = 0
  local correct = 0
  Citizen.CreateThread(function()--Main Thread for the hack
    Citizen.Wait(2500)
    while failed < 3  and correct < 1 do 
      local letter = math.random(1,12)
      exports['mythic_notify']:DoHudText('inform', 'Press ' .. buttons[letter].char)
      listening = true
      listenForPress(buttons[letter].value)
      Citizen.Wait(850) --Timer to press Key
      listening = false
      --Parsing the results of the loop
      if pressed then
        correct = correct + 1
        if correct == 1 then
          exports['mythic_notify']:DoShortHudText('success', 'Started Password Search')
        elseif correct == 2 then
          exports['mythic_notify']:DoShortHudText('success', 'Found Password')
        elseif correct == 3 then
          exports['mythic_notify']:DoShortHudText('success', 'Logging in')
        elseif correct == 4 then
          exports['mythic_notify']:DoShortHudText('success', 'Finding Firewall')
        elseif correct == 5 then
          exports['mythic_notify']:DoShortHudText('success', 'Firewall Found')
        elseif correct == 6 then
          exports['mythic_notify']:DoShortHudText('success', 'Disabling Firewall')
        elseif correct == 7 then
          exports['mythic_notify']:DoShortHudText('success', 'Firewall Disabled')
        elseif correct == 8 then
          exports['mythic_notify']:DoShortHudText('success', 'Checking for footprints')
        elseif correct == 9 then
          exports['mythic_notify']:DoShortHudText('success', 'Clearing footprints')
        else
          exports['mythic_notify']:DoShortHudText('success', 'Access Granted')
        end
      else
        failed = failed + 1
        exports['mythic_notify']:DoShortHudText('error', 'Failed to make progress')
      end
      pressed = false
      Citizen.Wait(2500)
    end
    if failed == 3 then
      exports['mythic_notify']:DoShortHudText('error', 'Hacking Failed')
      TriggerServerEvent('yp_bankrob:consumeDrive')
    else
      TriggerServerEvent('yp_bankrob:finishHack', bank)
    end
  end)
end)

RegisterNetEvent('yp_bankrob:displayAlarm')
AddEventHandler('yp_bankrob:displayAlarm', function(bank)
  blipRobbery = AddBlipForCoord(banks[bank].x, banks[bank].y, banks[bank].z)
  SetBlipSprite(blipRobbery , 161)
  SetBlipScale(blipRobbery , 2.0)
  SetBlipColour(blipRobbery, 3)
  PulseBlip(blipRobbery)
end)

RegisterNetEvent('yp_bankrob:killAlarm')
AddEventHandler('yp_bankrob:killAlarm', function()
  RemoveBlip(blipRobbery)
end)

RegisterNetEvent('yp_bankrob:resetClient')
AddEventHandler('yp_bankrob:resetClient', function(bank)
  banks[bank].hacked =  false
  resetDoor(bank)
end)

RegisterNetEvent('yp_bankrob:hackComplete')
AddEventHandler('yp_bankrob:hackComplete', function(bank)
  banks[bank].hacked = true
  openDoor(bank)
end)

RegisterNetEvent('yp_bankrob:startDrilling')
AddEventHandler('yp_bankrob:startDrilling', function(bank, drillNum)
  local drilling = true--Init Variables
  local count = 0
  local countMax = 0
  if banks[bank].name == 'Blaine County Savings' then--Get the amount of time this drill will take
    countMax = math.random(20,35)
  else
    countMax = math.random(15,30)
  end
  local drillSpot = banks[bank].drill[drillNum]
  local playerPed = GetPlayerPed(-1)
  Citizen.CreateThread(function()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
    exports['mythic_notify']:DoHudText('inform', 'Drilling Started')
    while drilling and count ~= countMax and not IsEntityDead(playerPed) do
      if math.random(1,200) <= 1 then
        exports['mythic_notify']:DoHudText('error', 'Your drillbit broke!')
        drilling = false
      else
        count = count + 1
      end
      Citizen.Wait(1000)
    end
    ClearPedTasksImmediately(playerPed)
    TriggerServerEvent('yp_bankrob:stopDrilling', bank, drillNum)
    if count == countMax then
      exports['mythic_notify']:DoHudText('success', 'Drilling successful!')
      TriggerServerEvent('yp_bankrob:drillFinish', bank, drillNum)
    end
    if IsEntityDead(playerPed) then
      exports['mythic_notify']:DoHudText('error', 'Drilling Cancelled')
    end
  end)
end)

RegisterNetEvent('yp_bankrob:drillDone')
AddEventHandler('yp_bankrob:drillDone', function(bank, drillNum)
  local drills = banks[bank].drill[drillNum]
  drills.drilled = true
end)


--Main Thread
Citizen.CreateThread(function()
  while not playerReady do
    Citizen.Wait(0) 
  end
  local playerPed = GetPlayerPed(-1)
  while true do
    local pos = GetEntityCoords(playerPed)
    for i, v in pairs(banks) do
      local exit = v.exit
      if Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) <= 0.5 and not v.hacked then --Hacking prompts
        DisplayHelpText('Press ~INPUT_CONTEXT~ to Hack the door')
        if IsControlJustPressed(1,51) then
          TriggerServerEvent('yp_bankrob:startRob', i)
        end
      end
      if Vdist(pos.x, pos.y, pos.z, exit.x, exit.y, exit.z) < 1 then  --Leaving store
        TriggerServerEvent('yp_bankrob:leaveStore', i)
      end
      if v.hacked then
        drills = v.drill
        for j = 1, #drills, 1 do
          if Vdist(pos.x, pos.y, pos.z, drills[j].x, drills[j].y, drills[j].z) < 1  and not drills[j].drilled then
            DisplayHelpText('Press ~INPUT_CONTEXT~ to Drill the box')
            if IsControlJustPressed(1,51) then
              TriggerServerEvent('yp_bankrob:startDrill', i, j)
            end
          end
        end
      end
    end
    Citizen.Wait(0)
  end
end)