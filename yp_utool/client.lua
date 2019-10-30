local guiEnabled = false
local blip = nil

function EnableGui(enable)
	SetNuiFocus(enable, enable)
	guiEnabled = enable

	SendNUIMessage({
		type = "enableui",
		enable = enable
	})
end

RegisterNUICallback('exit', function(data, cb)
	EnableGui(false)
	cb('ok')
end)

RegisterNUICallback('buyWithCash', function(data, cb)
	local items = {['repairs'] = data.repairs, ['flares'] = data.flares, ['screwdrivers'] = data.screws, ['pliers'] = data.pliers}
	TriggerServerEvent('yp_utool:checkout', false, data.total, items)
	cb('ok')
end)

RegisterNUICallback('buyWithCard', function(data, cb)
	local items = {['repairs'] = data.repairs, ['flares'] = data.flares, ['screwdrivers'] = data.screws, ['pliers'] = data.pliers}
	TriggerServerEvent('yp_utool:checkout', true, data.total, items)
	cb('ok')
end)

Citizen.CreateThread(function() -- Create Blip for store
	blip = AddBlipForCoord(39.7347, -1735.2628, 29.3033)
	SetBlipSprite(blip, 566)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Hardware store")
	EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		if guiEnabled then
			DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown

            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate

            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
		end
		local dist = Vdist(pos.x, pos.y, pos.z, 45.5686, -1748.8684, 29.5975)
		local dist2 = Vdist(pos.x, pos.y, pos.z, 53.9046, -1738.3624, 29.5325)
		if dist < 20 then
			DrawMarker(1, 45.5686, -1748.8684, 28.5975, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			if dist < 2 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to shop')
				if IsControlJustPressed(0,51) then
					EnableGui(true)
				end
			end
		end

		if dist2 < 20 then
			DrawMarker(1, 53.9046, -1738.3624, 28.5325, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 1.0, 0, 0, 255, 100, false, false, 2, false, nil, nil, false)
			if dist2 < 2 then
				exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to shop')
				if IsControlJustPressed(0,51) then
					EnableGui(true)
				end
			end
		end
		Citizen.Wait(0)
	end
end)
