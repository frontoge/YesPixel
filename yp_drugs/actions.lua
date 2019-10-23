
function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

RegisterNetEvent('yp_drugs:actions:useCocaine')
AddEventHandler('yp_drugs:actions:useCocaine', function(source)

end)

RegisterNetEvent('yp_drugs:actions:useMeth')
AddEventHandler('yp_drugs:actions:useMeth', function(source)
	
end)

RegisterNetEvent('yp_drugs:actions:useJoint')
AddEventHandler('yp_drugs:actions:useJoint', function(source)
	loadAnimDict('timetable@gardener@smoking_joint')
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local timer = 0
		local prop = CreateObject(GetHashKey('prop_sh_joint_01'), x, y, z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(playerPed, 0xFA10)

		AttachEntityToEntity(prop, playerPed, boneIndex, 0.03, 0.0, 0.02, 120.0, 190.0, 50.0, true, false, false, true, 1, true)
		TaskPlayAnim( playerPed, "timetable@gardener@smoking_joint", "smoke_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

		exports['yp_base']:FreezePlayer()
		while timer < 15 do
			Citizen.Wait(1000)
			timer = timer + 1
		end

		exports['yp_base']:removeStress(150000)
		TriggerEvent('esx_status:getStatus', 'drunk', function(status)
			status.add(100000)
		end)

		ClearPedTasksImmediately(playerPed)
		DeleteObject(prop)
		exports['yp_base']:UnFreezePlayer()

 	end)
end)

RegisterNetEvent('yp_drugs:actions:useBlunt')
AddEventHandler('yp_drugs:actions:useBlunt', function(source)
	loadAnimDict('timetable@gardener@smoking_joint')
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local timer = 0
		local prop = CreateObject(GetHashKey('prop_sh_joint_01'), x, y, z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(playerPed, 0xFA10)

		AttachEntityToEntity(prop, playerPed, boneIndex, 0.03, 0.0, 0.02, 120.0, 190.0, 50.0, true, false, false, true, 1, true)
		TaskPlayAnim( playerPed, "timetable@gardener@smoking_joint", "smoke_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

		exports['yp_base']:FreezePlayer()
		while timer < 15 do
			Citizen.Wait(1000)
			timer = timer + 1
		end

		exports['yp_base']:removeStress(200000)
		TriggerEvent('esx_status:getStatus', 'drunk', function(status)
			status.add(150000)
		end)

		ClearPedTasksImmediately(playerPed)
		DeleteObject(prop)
		exports['yp_base']:UnFreezePlayer()

 	end)
end)

RegisterNetEvent('yp_drugs:actions:useHeroin')
AddEventHandler('yp_drugs:actions:useHeroin', function(source)
	
end)

RegisterNetEvent('yp_drugs:actions:useXanax')
AddEventHandler('yp_drugs:actions:useXanax', function(source)
	
end)

RegisterNetEvent('yp_drugs:actions:useVicodin')
AddEventHandler('yp_drugs:actions:useVicodin', function(source)
	
end)

RegisterNetEvent('yp_drugs:actions:useLSD')
AddEventHandler('yp_drugs:actions:useLSD', function(source)
	
end)

RegisterNetEvent('yp_drugs:actions:rollWeed')
AddEventHandler('yp_drugs:actions:rollWeed', function(source, item)
	Citizen.CreateThread(function()
		local timer = 0
		local x = 0

		if item == 'blunt' then
			timer = 12
		else
			timer = 7
		end

		exports['progressBars']:StartUI(timer, "Rolling Weed")
		
		while x < timer do
			Citizen.Wait(1000)
			x = x + 1
		end

		TriggerServerEvent('yp_base:addItem', item, 1)
	end)
end)
