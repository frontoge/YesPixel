--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--Config Locals
local IdleDecay = 0.0001--Engine Percentage that will be lost per second
local DecayMultiplier = 0.0002--Multiplier affecting the rate engine decay while moving, Higher the number faster the decay.
local engineFactor = 10.0 --Rate at which collisions affect engine damage, higher the number the more damage per colision
local bodyFactor = 10.0 --Rate at which collisions affect body damage, 
local fuelFactor = 3.0 -- Rate at which collisions affect fueltank body damage

--Script Locals
local lastSpeed = 0

local engineCurrent = 1000.0
local engineLast = 1000.0
local engineDelta = 0.0
local engineScale = 0.0

local bodyCurrent = 1000.0
local bodyLast = 1000.0
local bodyDelta = 0.0
local bodyScale = 0.0

local fuelCurrent = 1000.0
local fuelLast = 1000.0
local fuelDelta = 0.0
local fuelScale = 0.0

--ESX init
ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

--Functions
function getEngineDecay(vehicle)
  local gear = GetVehicleCurrentGear(vehicle)
  local speed = GetEntitySpeed(vehicle)
  if GetIsVehicleEngineRunning(vehicle) then
    local decay = IdleDecay
    if speed ~= 0 then
      decay = (speed / (gear + 1)) * DecayMultiplier
    end
    return decay
  else return 0 end
end

local function isPedDrivingAVehicle()
	local ped = GetPlayerPed(-1)
	vehicle = GetVehiclePedIsIn(ped, false)
	if IsPedInAnyVehicle(ped, false) then
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			local class = GetVehicleClass(vehicle)
			if class ~= 15 and class ~= 16 and class ~=21 and class ~=13 then -- ignores trains, planes, boats, and bikes
				return true
			end
		end
	end
	return false
end

--Events
RegisterNetEvent('idd_repairengine')
AddEventHandler('idd_repairengine', function()
  local vehicle = ESX.Game.GetVehicleInDirection()
  local playerPed = GetPlayerPed(-1)
  if DoesEntityExist(vehicle) then
    if GetVehicleEngineHealth(vehicle) < 300.0 then
      exports['mythic_notify']:DoHudText('inform', 'You are repairing your vehicle')
      TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
  	  exports['progressBars']:startUI(7000, "Repairing Engine")
      Citizen.Wait(7000)
      SetVehicleEngineHealth(vehicle, 300.0)
      TriggerServerEvent('idd_consRepairKit')
      ClearPedTasksImmediately(playerPed)
      exports['mythic_notify']:DoLongHudText('success', 'You repaired your vehicle')
    else
      exports['mythic_notify']:DoLongHudText('error', 'Your vehicle is not damaged enough to repair')
    end
  end
end)

--Main Thread
Citizen.CreateThread(function()
  Citizen.Wait(500)
  local firstFrame = true
  while true do
    if isPedDrivingAVehicle() then
      local vehicle = ESX.Game.GetClosestVehicle()

      local roll = GetEntityRoll(vehicle)
      if (roll > 75.0 or roll < -75.0) then
          DisableControlAction(2,59,true) -- Disable left/right
          DisableControlAction(2,60,true) -- Disable up/down
      end

      SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fWeaponDamageMult', 0.01/bodyFactor)--Stop extreme weapon damage
      
      --Check for Damage To Engine
      engineCurrent = GetVehicleEngineHealth(vehicle)
      if firstFrame then
        engineLast = engineCurrent
        firstFrame = false
      end
      engineDelta = engineLast - engineCurrent
      if engineDelta > 0 then
        engineScale = engineFactor * engineDelta
        SetVehicleEngineHealth(vehicle, (engineLast - engineScale) - getEngineDecay(vehicle))
      else
        SetVehicleEngineHealth(vehicle, (engineLast - getEngineDecay(vehicle)))
      end
      
      if GetVehicleEngineHealth(vehicle) < 100.0 then -- Keep Vehicle From hitting zero engine Health
          SetVehicleEngineHealth(vehicle, 100.0)
      end
      engineLast = GetVehicleEngineHealth(vehicle)
      
      --Check For Body Damage
      bodyCurrent = GetVehicleBodyHealth(vehicle)
      bodyDelta = bodyLast - bodyCurrent
      if bodyDelta > 0 then
        bodyScale = bodyDelta * bodyFactor
        SetVehicleBodyHealth(vehicle, bodyLast - bodyScale)
        if GetVehicleBodyHealth(vehicle) < 0 then
          SetVehicleBodyHealth(vehicle, 0)
        end
      end
      bodyLast = GetVehicleBodyHealth(vehicle)
      --Check for fueltank damage
      fuelCurrent = GetVehiclePetrolTankHealth(vehicle)
      fuelDelta = fuelLast - fuelCurrent
      if fuelDelta > 0 then
        fuelScale = fuelDelta * fuelFactor
        SetVehiclePetrolTankHealth(vehicle, fuelCurrent - fuelScale)
      end
      fuelLast = GetVehiclePetrolTankHealth(vehicle)
      
      --Disable Vehicle
      if GetVehicleEngineHealth(vehicle) <= 200.0 or GetVehicleBodyHealth(vehicle) <= 0.0 then
        SetVehicleUndriveable(vehicle, true)
      else
        SetVehicleUndriveable(vehicle, false)
      end
    else 
      firstFrame = true
    end
    Citizen.Wait(0)-- Check every Frame
  end
end)
