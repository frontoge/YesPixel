--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--items
ESX.RegisterUsableItem('repairkit', function(source)
  TriggerClientEvent('idd_repairengine', source)
end)

RegisterServerEvent('idd_consRepairKit')
AddEventHandler('idd_consRepairKit', function()
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem('repairkit', 1)
end)