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
	SendNUIMessage({
		type = 'laws',
		laws = lawbook,
	})
end)

RegisterNetEvent('yp_cad:getPlayerInfo')
AddEventHandler('yp_cad:getPlayerInfo', function(data, type)
	SendNUIMessage({
		type = 'records',
		results = data,
		category = type
	})
end)

RegisterNetEvent('yp_cad:getWarrants')
AddEventHandler('yp_cad:getWarrants', function(warrantList)
	SendNUIMessage({
		type = 'warrants',
		results = warrantList
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
	
end

--NUI callbacks
RegisterNUICallback('exit', function(data, cb)
	uiEnabled = false
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNUICallback('searchRecords', function(data, cb)	
	TriggerServerEvent('yp_cad:findPlayerInfo', data.name, data.type)
	cb('ok')
end)

RegisterNUICallback('fileReport', function(data, cb)
	TriggerServerEvent('yp_cad:updateRecords', data.target, data.charges)
	cb('ok')
end)


--Warrant Callbacks
RegisterNUICallback('createWarrant', function(data, cb)
	TriggerServerEvent('yp_cad:addWarrant', data)
	cb('ok')
end)

RegisterNUICallback('requestWarrants', function(data, cb)
	TriggerServerEvent('yp_cad:fetchWarrants', data.name)
	cb('ok')
end)

RegisterNUICallback('respondWarrant', function(data, cb)
	TriggerServerEvent('yp_cad:updateWarrantStatus', data.type, data.id)
	cb('ok')
end)

RegisterNUICallback('closeWarrant', function(data, cb)
	TriggerServerEvent('yp_cad:closeWarrant', data.id)
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
