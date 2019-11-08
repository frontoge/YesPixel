--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local uiEnabled = false
local rate = 4.00
local total = 10.00
local running = false

function enableUI(enable)
	uiEnabled = enable
	SendNUIMessage({
		type = 'ui',
		enable = enable,
		total = total,
		rate = rate
	})
end

RegisterNetEvent('yp_taxi:updateRate')
AddEventHandler('yp_taxi:updateRate', function(newRate)
	rate = newRate
	SendNUIMessage({
		type = 'update',
		element = 'rate',
		value = rate
	})
end)

--Meter thread
Citizen.CreateThread(function()
	local counter = 0
	while true do
		if uiEnabled and running then
			Citizen.Wait(500)
			counter = counter+1
			print(counter)
			if counter >= 120 then
				counter = 0
				total = total+ rate
				SendNUIMessage({
					type = 'update',
					element = 'total',
					value = total
				})
			end
		else
			Citizen.Wait(0)
		end
	end
end)

--Main thread opens and closes UI
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed)
			if (GetHashKey('taxi') == GetEntityModel(vehicle)) then
				if IsControlJustPressed(0, 167) then
					if uiEnabled then
						enableUI(false)
					else
						enableUI(true)
					end
				end
				if IsControlJustPressed(0, 29) and uiEnabled then --B
					total = 10.00
					SendNUIMessage({
						type = 'update',
						element = 'total',
						value = total
					})
				end

				if IsControlJustPressed(0, 236) and uiEnabled then --V
					if running then
						running = false
						SendNUIMessage({
							type = 'stop'
						})
					else
						running = true
						SendNUIMessage({
							type = 'start'
						})
					end
				end
			end
		else
			if uiEnabled then
				enableUI(false)
			end
		end
		Citizen.Wait(0)
	end
end)