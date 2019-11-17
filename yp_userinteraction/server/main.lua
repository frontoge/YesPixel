--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Events
RegisterServerEvent('getplayerdata')
AddEventHandler('getplayerdata', function()
    local _source = source
    local player = ESX.GetPlayerFromId(_source)
    
    
    MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {--Get Data to be displayed on ID
			['@identifier'] = player.identifier }, function(result)
          data = {}
          table.insert(data, firstname)
          data.firstname = result[1].firstname
          table.insert(data, lastname)
          data.lastname = result[1].lastname
          table.insert(data, dob)
          data.dob = result[1].dateofbirth
          table.insert(data, sex)
          data.sex = result[1].sex
          table.insert(data, height)
          data.height = result[1].height
          
          TriggerClientEvent('showmyid', _source, data)--Send Data Back to client for display
      end)
end)

RegisterServerEvent('checkforpick')
AddEventHandler('checkforpick', function()
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer.job.name == 'police' or xPlayer.job.name == 'fib' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'sheriff' then
    TriggerClientEvent('yp_userinteraction:lockpickvehicle', source)
  elseif xPlayer.getInventoryItem('lockpick').count >= 1 then
    xPlayer.removeInventoryItem('lockpick', 1)
    TriggerClientEvent('yp_userinteraction:lockpickvehicle', source)
  else
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You need a lockpick!' })
  end
end)

RegisterServerEvent('cuff')
AddEventHandler('cuff', function(target)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if not (xPlayer.job.name == 'police' or xPlayer.job.name == 'fib' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'sheriff') then
    if xPlayer.getInventoryItem('handcuffs').count >= 1 then
      TriggerClientEvent('yp_userinteraction:getcuffed', target)
      xPlayer.removeInventoryItem('handcuffs', 1)
    end
  else
    TriggerClientEvent('yp_userinteraction:getcuffed', target)
  end
end)

RegisterServerEvent('uncuff')
AddEventHandler('uncuff', function(target)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if not (xPlayer.job.name == 'police' or xPlayer.job.name == 'fib' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'sheriff') then
    if xPlayer.getInventoryItem('handcuffkey').count >= 1 then
      TriggerClientEvent('yp_userinteraction:getuncuffed', target)
      xPlayer.addInventoryItem('handcuffs', 1)
    end
  else
    TriggerClientEvent('yp_userinteraction:getuncuffed', target)
  end
end)

RegisterServerEvent('escort')
AddEventHandler('escort', function(target)
  local source = source
  TriggerClientEvent('yp_userinteraction:escort', target, source)
  
end)

RegisterServerEvent('yp_userinteraction:putInVehicle')
AddEventHandler('yp_userinteraction:putInVehicle', function(target)
  local source = source
  TriggerClientEvent('putInVehicle', target)
  
end)

RegisterServerEvent('yp_userinteraction:pullOutVehicle')
AddEventHandler('yp_userinteraction:pullOutVehicle', function(target)
  local source = source
  TriggerClientEvent('pullOutVehicle', target)
  
end)

RegisterServerEvent('yp_userinteraction:getPlayerInventory')
AddEventHandler('yp_userinteraction:getPlayerInventory', function(target)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(target)
  local targetInv = {inventory = xPlayer.inventory, weapons = xPlayer.loadout, accounts = xPlayer.accounts}
  
  TriggerClientEvent('yp_userinteraction:showPlayerInventory', source, target, targetInv)
end)

RegisterServerEvent('takePlayerItem')
AddEventHandler('takePlayerItem', function(item, amount, itemType, target)
  local xPlayer = ESX.GetPlayerFromId(target)
  if itemType == 'item' then
    if xPlayer.getInventoryItem(item).count >= amount then
      xPlayer.removeInventoryItem(item, amount)
      xPlayer = ESX.GetPlayerFromId(source)
      xPlayer.addInventoryItem(item, amount)
    end
  elseif itemType == 'weapon' then
    if amount == nil then amount = 0 end
    xPlayer.removeWeapon(item, amount)
    xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addWeapon(item, amount)
  
  elseif itemType == 'account' then
    xPlayer.removeAccountMoney(item, amount)
    xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney(item, amount)
  end
end)

--Chat Commands
RegisterCommand('coords', function(source, args)
  local xPlayer = ESX.GetPlayerFromId(source)
  local coords = xPlayer.getCoords()
  print(coords.x, coords.y, coords.z)
end)


RegisterCommand('myid', function(source, args)
  TriggerClientEvent('startid', source)
  
end, false)

RegisterCommand('door', function(source, args)
  TriggerClientEvent('toggledoor', source,  0)
  
end, false)

RegisterCommand('door2', function(source, args)
  TriggerClientEvent('toggledoor', source, 1)
  
end, false)

RegisterCommand('door3', function(source, args)
  TriggerClientEvent('toggledoor', source, 2)
  
end, false)

RegisterCommand('door4', function(source, args)
  TriggerClientEvent('toggledoor', source, 3)
  
end, false)

RegisterCommand('hood', function(source, args)
  TriggerClientEvent('toggledoor', source, 4)
  
end, false)

RegisterCommand('trunk', function(source, args)
  TriggerClientEvent('toggledoor', source, 5)
  
end, false)

RegisterCommand('wu', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 0, true)
  
end, false)

RegisterCommand('wu2', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 1, true)
  
end, false)

RegisterCommand('wu3', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 2, true)
  
end, false)

RegisterCommand('wu4', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 3, true)
  
end, false)

RegisterCommand('wd', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 0, false)
  
end, false)

RegisterCommand('wd2', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 1, false)
  
end, false)

RegisterCommand('wd3', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 2, false)
  
end, false)

RegisterCommand('wd4', function(source, args)
  TriggerClientEvent('userinteraction:windowcommand', source, 3, false)
  
end, false)

--Items
ESX.RegisterUsableItem('idcard', function(source)
  TriggerClientEvent('startid', source)
end)

ESX.RegisterUsableItem('lockpick', function(source)
  
  TriggerClientEvent('yp_userinteraction:lockpickvehicle', source)
    
end)
