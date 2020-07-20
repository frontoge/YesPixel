ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('rebreather', function(source)
    TriggerClientEvent('bolls:rebreather', source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('rebreather', 1)
  end)
  
  ESX.RegisterUsableItem('scubatank', function(source)
    TriggerClientEvent('bolls:scubaTank', source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('scubatank', 1)
  end)