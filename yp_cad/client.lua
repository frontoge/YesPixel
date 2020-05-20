--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local YPlayer = nil
local lawbook = {}

--Event Handlers
RegisterNetEvent('yp:playerLoaded')
AddEventHandler('yp:playerLoaded', function()
	YPlayer = exports.yp_base:getYPlayer()
	TriggerServerEvent('yp_cad:getLawbook')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	YPlayer.job = job.name
end)

RegisterNetEvent('yp_cad:storeLawbook')
AddEventHandler('yp_cad:storeLawbook', function(laws)
	lawbook = laws
	print(laws)
	print(lawbook)
end)

RegisterNetEvent('yp_cad:getPlayerInfo')
AddEventHandler('yp_cad:getPlayerInfo', function(data, type)
	SendNUIMessage({
		type = 'records',
		results = data,
		category = type
	})
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
	SendNUIMessage({
		type = 'laws',
		laws = lawbook,
		size = #lawbook
	})
end

--NUI callbacks
RegisterNUICallback('exit', function(data, cb)
	uiEnabled = false
	SetNuiFocus(false, false)
	cb('ok')
end)

--[[RegisterNUICallback('getLaws', function(data, cb)
	SendNUIMessage({
		type = 'laws',
		laws = lawbook,
		size = #lawbook
	})
	cb('ok')
end)]]

RegisterNUICallback('searchRecords', function(data, cb)	
	TriggerServerEvent('yp_cad:findPlayerInfo', data.name, data.type)
	cb('ok')
end)

RegisterNUICallback('fileReport', function(data, cb)
	print('report filed')
	TriggerServerEvent('yp_cad:updateRecords', data.target, data.charges)
	cb('ok')
end)

--Commands
RegisterCommand('exitui', function(source, args)
	uiEnabled = false
	SetNuiFocus(false, false)
end)

RegisterCommand('getPlayer', function(source, args)
	YPlayer = exports.yp_base:getYPlayer()
	TriggerServerEvent('yp_cad:getLawbook')
end)

RegisterCommand('cad', function(source, args)
	local name = string.sub(YPlayer.firstname, 1, 1) .. YPlayer.lastname
	enableUI(true, YPlayer.job, name)
end)
