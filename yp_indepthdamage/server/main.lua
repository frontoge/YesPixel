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