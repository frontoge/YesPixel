--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local collecting = false
local playerReady = false
local blipRobbery = nil

class0Wep = {'WEAPON_KNIFE', 'WEAPON_NIGHTSTICK', 'WEAPON_HAMMER', 'WEAPON_BAT', 'WEAPON_GOLFCLUB', 'WEAPON_CROWBAR'}
class1Wep = {'WEAPON_PISTOL', 'WEAPON_COMBATPISTOL', 'WEAPON_PISTOL50', 'WEAPON_REVOLVER', 'WEAPON_SNSPISTOL', 'WEAPON_HEAVYPISTOL', 'WEAPON_VINTAGEPISTOL', 'WEAPON_PUMPSHOTGUN', 'WEAPON_SAWNOFFSHOTGUN'}
class2Wep = {'WEAPON_APPISTOL', 'WEAPON_MICROSMG', 'WEAPON_SMG', 'WEAPON_MINISMG', 'WEAPON_MACHINEPISTOL', 'WEAPON_ASSAULTSHOTGUN', 'WEAPON_BULLPUPSHOTGUN', 'WEAPON_HEAVYSHOTGUN'}
class3Wep = {'WEAPON_ASSAULTSMG', 'WEAPON_COMBATPDW', 'WEAPON_ASSAULTRIFLE', 'WEAPON_CARBINERIFLE', 'WEAPON_ADVANCEDRIFLE', 'WEAPON_SPECIALCARBINE', 'WEAPON_BULLPUPRIFLE', 'WEAPON_COMPACTRIFLE'}



local cases = {
  {x = -626.5326, y = -238.3758, z = 38.05, robbed = false},
  {x = -625.6032, y = -237.5273, z = 38.05, robbed = false},
  {x = -626.9178, y = -235.5166, z = 38.05, robbed = false},
  {x = -625.6701, y = -234.6061, z = 38.05, robbed = false},
  {x = -626.8935, y = -233.0814, z = 38.05, robbed = false}, 
  {x = -627.9514, y = -233.8582, z = 38.05, robbed = false}, 
  {x = -624.5250, y = -231.0555, z = 38.05, robbed = false},
  {x = -623.0003, y = -233.0833, z = 38.05, robbed = false},
  {x = -620.1098, y = -233.3672, z = 38.05, robbed = false},
  {x = -620.2979, y = -234.4196, z = 38.05, robbed = false},
  {x = -619.0646, y = -233.5629, z = 38.05, robbed = false},
  {x = -617.4846, y = -230.6598, z = 38.05, robbed = false},
  {x = -618.3619, y = -229.4285, z = 38.05, robbed = false},
  {x = -619.6064, y = -230.5518, z = 38.05, robbed = false},
  {x = -620.8951, y = -228.6519, z = 38.05, robbed = false},
  {x = -619.7905, y = -227.5623, z = 38.05, robbed = false},
  {x = -620.6110, y = -226.4467, z = 38.05, robbed = false},
  {x = -623.9951, y = -228.1755, z = 38.05, robbed = false},
  {x = -624.8832, y = -227.8645, z = 38.05, robbed = false},
  {x = -623.6746, y = -227.0025, z = 38.05, robbed = false}} 
                        


--ESX init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--Functions
function checkWepClass(weaponHash)
  for i, v in ipairs(class0Wep) do
    if GetHashKey(v) == weaponHash then
      return 0
    end
  end
  for i, v in ipairs(class1Wep) do
    if GetHashKey(v) == weaponHash then
      return 1
    end
  end
  for i, v in ipairs(class2Wep) do
    if GetHashKey(v) == weaponHash then
      return 2
    end
  end
  for i, v in ipairs(class3Wep)
  do
    if GetHashKey(v) == weaponHash then
      return 3
    end
  end
  return -1
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

--Events
RegisterNetEvent('yp_jewelry:playerReady')
AddEventHandler('yp_jewelry:playerReady', function()
  playerReady = true
end)

RegisterNetEvent('breakCase')
AddEventHandler('breakCase', function(caseNumber)
  local playerPed = GetPlayerPed(-1)
  local weaponClass = checkWepClass(GetSelectedPedWeapon(playerPed))
  if weaponClass ~= -1 then
    TriggerServerEvent('tripAlarm')
    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", cases[caseNumber].x, cases[caseNumber].y, cases[caseNumber].z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
		loadAnimDict( "missheist_jewel" ) 
		TaskPlayAnim( playerPed, "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0 ) 
    collecting = true
		DisplayHelpText('Collection in progress')
		DrawSubtitleTimed(5000, 1)
		Citizen.Wait(5000)
		ClearPedTasksImmediately(playerPed)
    TriggerServerEvent('robCase', caseNumber, weaponClass)
    collecting = false
  else
    exports['mythic_notify']:DoHudText('error', 'You need a weapon to break the glass!')
  end
end)

RegisterNetEvent('toggleCase')
AddEventHandler('toggleCase', function(caseNumber)
  cases[caseNumber].robbed = true
end)

RegisterNetEvent('resetCases')
AddEventHandler('resetCases', function()
  for i, v in ipairs(cases) do
    v.robbed = false
  end
end)

RegisterNetEvent('alarmBlip')
AddEventHandler('alarmBlip', function(position)
    blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 3)
    PulseBlip(blipRobbery)
end)

RegisterNetEvent('killAlarm')
AddEventHandler('killAlarm', function()
  RemoveBlip(blipRobbery)
end)

--Main Thread 
Citizen.CreateThread(function()
  while not playerReady do
    Citizen.Wait(0)
  end
  local playerPed = GetPlayerPed(-1)
  while true do --Every Frame Loop
    local pos = GetEntityCoords(playerPed)
    for i, v in ipairs(cases) do
      if Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 0.5 and not collecting then
        if not v.robbed then
          DisplayHelpText('Press E to rob')
          if IsControlJustPressed(1, 51) then
            print('robbing case')
            TriggerServerEvent('yp_jewelry:startCase', i)
          end
        end
      end
    end
    if Vdist(pos.x, pos.y, pos.z, -631.1049, -237.5149, 38.0796) < 1 then
      TriggerServerEvent('leaveStore')
    end
    if Vdist(pos.x, pos.y, pos.z, 1109.9660, -2008.2534, 31.0616) <= 5 then
      if not sellingJewels then
        TriggerServerEvent('sellJewelry')
        sellingJewels = true
      end
    end
    if Vdist(pos.x, pos.y, pos.z, 718.2935, -974.9028, 24.9141) <= 1 then
      sellingJewels = false
    end
    Citizen.Wait(0)
  end
end)
