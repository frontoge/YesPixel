Citizen.CreateThread(function() 
    while true do
    	SetCreateRandomCops(false)
        --Prevent Weapons from dropping by Peds
        RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_CARBINERIFLE'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PISTOL'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_PUMPSHOTGUN'))
		RemoveAllPickupsOfType(GetHashKey('PICKUP_WEAPON_COMBATPISTOL'))

		--Limit Number of Peds	
        SetParkedVehicleDensityMultiplierThisFrame(0.1)
        SetVehicleDensityMultiplierThisFrame(0.3)
        SetRandomVehicleDensityMultiplierThisFrame(0.3)
        SetPedDensityMultiplierThisFrame(0.5)
		SetScenarioPedDensityMultiplierThisFrame(0.1, 0.1)
		
		for i, v in ipairs(NoSpawn) do
			SetPedModelIsSuppressed(v, true)
		end

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