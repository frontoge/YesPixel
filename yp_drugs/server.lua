--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('cocaine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cocaine', 1)
	TriggerClientEvent('yp_drugs:actions:useCocaine', source)
end)

ESX.RegisterUsableItem('meth', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('meth', 1)
	TriggerClientEvent('yp_drugs:actions:useMeth', source)
end)

ESX.RegisterUsableItem('joint', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('joint', 1)
	TriggerClientEvent('yp_drugs:actions:useJoint', source)
end)

ESX.RegisterUsableItem('heroin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('heroin', 1)
	TriggerClientEvent('yp_drugs:actions:useHeroin')
end)

ESX.RegisterUsableItem('xanax', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('xanax', 1)
	TriggerClientEvent('yp_drugs:actions:useXanax', source)
end)

ESX.RegisterUsableItem('vicoidn', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicoidn', 1)
	TriggerClientEvent('yp_drugs:actions:useVicodin', source)
end)

ESX.RegisterUsableItem('lsd', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('lsd', 1)
	TriggerClientEvent('yp_drugs:actions:useLSD', source)
end)