--[[Citizen.CreateThread(function()
    while true do
        for ped in EnumeratePeds() do
            if DoesEntityExist(ped) then
				for i,model in pairs(cfg.noguns) do
					if (GetEntityModel(ped) == GetHashKey(model)) then
						RemoveAllPedWeapons(ped, true)
					end
				end
				for i,model in pairs(cfg.nodrops) do
					if (GetEntityModel(ped) == GetHashKey(model)) then
						SetPedDropsWeaponsWhenDead(ped,false) 
					end
				end
			end
		end
		Citizen.Wait(1000) 
    end
end)]]--

Citizen.CreateThread(function() 
    while true do
    	SetCreateRandomCops(false)
        --Prevent Weapons from dropping by Peds
        RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_CARBINERIFLE'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PISTOL'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PUMPSHOTGUN'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_COMBATPISTOL'))
		--Limit Number of Peds
        SetPedDensityMultiplierThisFrame(cfg.density.peds)
        SetScenarioPedDensityMultiplierThisFrame(cfg.density.peds, cfg.density.peds)
        SetVehicleDensityMultiplierThisFrame(cfg.density.vehicles)
        SetRandomVehicleDensityMultiplierThisFrame(cfg.density.vehicles)
        SetParkedVehicleDensityMultiplierThisFrame(cfg.density.vehicles)
        --Prevent Vehicles from dropping Weapons
        DisablePlayerVehicleRewards(PlayerId())
        --Prevent Dispatched NPC's
        for i = 1, 15 do
			EnableDispatchService(i, false)
		end
		ClearAreaOfCops(416.7775, -984.0160, 29.4289, 1000, 0)
        Citizen.Wait(0)
    end
end)