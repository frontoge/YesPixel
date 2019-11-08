function popTire(vehicle, tireNum)
	local num = math.random(1, 100)
	if num >= 60 then
		SetVehicleWheelHealth(vehicle, tireNum, 0.0)
	end
end

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed)
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then	
				local x, y, z = table.unpack(GetEntityCoords(vehicle))
				local strip = GetClosestObjectOfType(x, y, z, 3.0, GetHashKey('p_ld_stinger_s'))
				if DoesEntityExist(strip) then
					if IsEntityTouchingEntity(vehicle, strip) then
						popTire(vehicle, 0)
						popTire(vehicle, 1)
						popTire(vehicle, 2)
						popTire(vehicle, 3)

					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)