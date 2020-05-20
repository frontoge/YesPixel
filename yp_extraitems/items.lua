Items =
{
	['armor'] = 
	function()
		SetPedArmour(GetPlayerPed(-1), 100)
		SetPedComponentVariation(GetPlayerPed(-1), 9, 2, 0, 2)
		Citizen.CreateThread(function()
			while GetPedArmour(GetPlayerPed(-1)) > 0 do
				Citizen.Wait(0)
			end
			SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 0, 2)
		end)
	end
}