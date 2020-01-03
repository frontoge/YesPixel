function popTire(vehicle, tireNum)
	local num = math.random(1, 100)
	if num >= 85 then
		SetVehicleTyreBurst(vehicle, tireNum, true, 1000.0)
	end
end

local bursting = false

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
						if not bursting then
							for i = 0, 7, 1 do
								if not IsVehicleTyreBurst(vehicle, i, true) then
									popTire(vehicle, i)
								end
							end
							bursting = true
						end
					elseif bursting then
						bursting = false
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)