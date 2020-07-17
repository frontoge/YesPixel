function EnableUi(items)
	SetNuiFocus(true, true)

	SendNUIMessage({
		type = "enable",
		items = items
	})
end

function DrawText3D(x,y,z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.4, 0.4)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextDropShadow(50, 50, 50, 50)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 30, 11, 30, 68)
    end
end

RegisterNUICallback('exit', function(data, cb)
	print('exit')
	SetNuiFocus(false, false)
	cb('ok')
end)

Citizen.CreateThread(function() -- Create Blip for store
	for i, v in ipairs(StoreBlips) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, 566)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.0)
		SetBlipColour(blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Hardware store")
		EndTextCommandSetBlipName(blip)
	end
end)

RegisterNetEvent('yp_utool:sendLimits')
AddEventHandler('yp_utool:sendLimits', function(itemData)
	EnableUi(itemData)
end)

RegisterNetEvent('yp_utool:clear')
AddEventHandler('yp_utool:clear', function()
	TriggerServerEvent('yp_utool:getLimits', ItemData)
	SendNUIMessage({
		type='clear'
	})
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		for i, v in ipairs(Stores) do 
			local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
			if dist < 20 then
				DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.00, 1.00, 1.0, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
				if dist < 2 then 
					DrawText3D(v.x, v.y, v.z, "Press E to shop")
					if IsControlJustPressed(0, 51) then
						TriggerServerEvent('yp_utool:getLimits', ItemData)
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end)

--NUI Callbacks
RegisterNUICallback('checkoutCash', function(data, cb)
	local price = 0

	for i, v in pairs(data) do
		price = price + (ItemData[i].price * v)
	end

	TriggerServerEvent('yp_utool:checkout', data, price, false)

	cb('ok')
end)

RegisterNUICallback('checkoutCard', function(data, cb)
	local price = 0

	for i, v in pairs(data) do
		price = price + (ItemData[i].price * v)
	end

	TriggerServerEvent('yp_utool:checkout', data, price, true)

	cb('ok')
end)
