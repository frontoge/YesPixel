--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--Events
RegisterNetEvent('yp_base:disableHPRegen')
AddEventHandler('yp_base:disableHPRegen', function()
	local playerPed = GetPlayerPed(-1)
	SetPlayerHealthRechargeMultiplier(playerPed, 0.0)
end)