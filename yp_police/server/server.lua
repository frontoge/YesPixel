--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Events
RegisterServerEvent('yp_police:cuffPlayer')
AddEventHandler('yp_police:cuffPlayer', function(target)
	TriggerClientEvent('yp_userinteraction:getcuffed', target)
end)

RegisterServerEvent('yp_police:uncuffPlayer')
AddEventHandler('yp_police:uncuffPlayer', function(target)
	TriggerClientEvent('yp_userinteraction:getuncuffed', target)
end)

RegisterServerEvent('yp_police:escort')
AddEventHandler('yp_police:escort', function(target)
	local src = source
	TriggerClientEvent('yp_userinteraction:escort', target, src)
end)

RegisterServerEvent('yp_police:getPlayerInfo')
AddEventHandler('yp_police:getPlayerInfo', function(target)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(target)
	MySQL.Async.fetchAll('SELECT job, firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {--Get Data to be displayed on ID
			['@identifier'] = xPlayer.identifier }, function(result)
          local data = {}
          table.insert(data, job)
          data.job = result[1].job
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
          
          TriggerClientEvent('yp_police:viewId', src, data)--Send Data Back to client for display
      end)

end)

RegisterServerEvent('yp_police:getInvData')
AddEventHandler('yp_police:getInvData', function()
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)
     local invData = {inventory = xPlayer.inventory, weapons = xPlayer.loadout, accounts = xPlayer.accounts}
     TriggerClientEvent('yp_police:showPlayerInv', src, invData)
end)

RegisterServerEvent('yp_police:depositItem')
AddEventHandler('yp_police:depositItem', function(value, amount, itemType)
     local xPlayer = ESX.GetPlayerFromId(source)
     if itemType == 'item' then
          xPlayer.removeInventoryItem(value, amount)
     elseif itemType == 'weapon' then
          xPlayer.removeWeapon(value, 0)
     elseif itemType == 'account' then
          xPlayer.removeAccountMoney(value, amount)
     end
end)

RegisterServerEvent('yp_police:buyWeapon')
AddEventHandler('yp_police:buyWeapon', function(weaponName, cost)
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)
     --Charge the city
     TriggerEvent('esx_addonaccount:getSharedAccount', 'society_city', function(account)
          account.removeMoney(cost)
     end)
     --Give The weapon
     xPlayer.addWeapon(weaponName, 250)
end)

