--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local YPlayer = nil

RegisterNetEvent('yp:playerLoaded')
AddEventHandler('yp:playerLoaded', function()
	YPlayer = exports.yp_base:getYPlayer()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	YPlayer.job = job.name
end)

local uiEnabled = false

--UI Functions
function enableUI(enable, job, name)
	SetNuiFocus(enable, enable)
	uiEnabled = enable
	SendNUIMessage({
		type = "ui",
		enable = enable,
		job = job,
		name = name
	})
end

RegisterNUICallback('exit', function(data, cb)
	uiEnabled = false
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterCommand('exitui', function(source, args)
	uiEnabled = false
	SetNuiFocus(false, false)
end)

RegisterCommand('getPlayer', function(source, args)
	YPlayer = exports.yp_base:getYPlayer()
end)

RegisterCommand('cad', function(source, args)
	local name = string.sub(YPlayer.firstname, 1, 1) .. YPlayer.lastname
	print(YPlayer.job)
	enableUI(true, YPlayer.job, name)
end)
