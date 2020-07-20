ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

local level = 100

RegisterNetEvent('bolls:rebreather')
AddEventHandler('bolls:rebreather', function()
  exports['yp_progressbar']:startBar({{"Putting on Rebreather", 2200}}, nil, nil, 1, nil)
  Citizen.Wait(2500)
  OxygenText()
  Citizen.CreateThread(function()
    local ped = GetPlayerPed(-1)
    SetPedScubaGearVariation(ped)
    while level > 0 do
      SetPedDiesInWater(ped, false)
      if IsPedSwimmingUnderWater(ped) then
        Citizen.Wait(2000)
        level = level - 1
      end
      Citizen.Wait(0)
    end
      SetPedDiesInWater(ped, true)
      ClearPedScubaGearVariation(ped) 
  end)
end)


RegisterNetEvent('bolls:scubaTank')
AddEventHandler('bolls:scubaTank', function()
  local playerPed  = GetPlayerPed(-1)
  local coords     = GetEntityCoords(playerPed)
  local boneIndex  = GetPedBoneIndex(playerPed, 12844)
  local boneIndex2 = GetPedBoneIndex(playerPed, 24818)

  exports['yp_progressbar']:startBar({{"Putting on Tank", 9000}}, nil, nil, 1, nil)
  Citizen.Wait(10000)

  OxygenText()

  Citizen.CreateThread(function()

    ESX.Game.SpawnObject('p_s_scuba_mask_s', {
      x = coords.x,
      y = coords.y,
      z = coords.z - 3
    }, function(object)
      ESX.Game.SpawnObject('p_s_scuba_tank_s', {
        x = coords.x,
        y = coords.y,
        z = coords.z - 3
      }, function(object2)
        AttachEntityToEntity(object2, playerPed, boneIndex2, -0.30, -0.22, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
        AttachEntityToEntity(object, playerPed, boneIndex, 0.0, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)

        while level > 0 do 
          SetPedDiesInWater(playerPed, false)
          if IsPedSwimmingUnderWater(playerPed) then
            Citizen.Wait(4000)
            level = level - 1
          end
            SetPedDiesInWater(playerPed, true)

          Citizen.Wait(0)
        end

        exports['yp_progressbar']:startBar({{"Taking off Tank", 2250}}, nil, nil, 1, nil)
        Citizen.Wait(3000)
        DeleteObject(object)
        DeleteObject(object2)
        ClearPedSecondaryTask(playerPed)
        level = 100

      end)
    end)
  end)
end)

function OxygenText()
  Citizen.CreateThread(function()
    while level > 0 do
    exports['yp_text']:Draw2DText(0.158, 0.965, 'Oxygen:' .. level, 0.4, 7)
    Citizen.Wait(0)
    end
  end)
end

RegisterCommand("rbo", function()
  local ped = GetPlayerPed(-1)
  level = 0
  ClearPedScubaGearVariation(ped)
  Citizen.Wait(100)
  level = 100
end)