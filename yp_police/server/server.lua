--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local cops = {}
local numCops = 0

--Functions
function getNumCops()
     return numCops
end

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
AddEventHandler('yp_police:buyWeapon', function(name, cost)
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)
     --Charge the city
     TriggerEvent('esx_addonaccount:getSharedAccount', 'society_city', function(account)
          account.removeMoney(cost)
     end)

     if string.find(name, "WEAPON") ~= nil then
          --Give The weapon
          xPlayer.addWeapon(name, 250)
     else
          if xPlayer.getInventoryItem(name).count < xPlayer.getInventoryItem(name).limit then
               xPlayer.addInventoryItem(name, 1)
          else
               TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'error', text = 'You are already carrying a ' .. name, length = 3000})
          end
     end

end)

RegisterServerEvent('yp_police:getUserJob')
AddEventHandler('yp_police:getUserJob', function()
     local src = source
     local isCop = false
     local xPlayer = ESX.GetPlayerFromId(src)
     if xPlayer.job.name == 'police' then
          isCop = true
          if xPlayer.job.grade == 8 then
          TriggerClientEvent('yp_police:makeBoss', src)
          end
     end
     TriggerClientEvent('yp_police:setJob', src, isCop)
end)

RegisterServerEvent('yp_police:getUniform')
AddEventHandler('yp_police:getUniform', function()
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)

     local jobGrade = xPlayer.job.grade
     local sexChar = nil
     MySQL.Async.fetchAll('SELECT sex FROM users WHERE identifier = @identifier', {
               ['@identifier'] = xPlayer.identifier }, 
          function(result)
               sexChar = result[1].sex
               print(sexChar)
               local skin = {}
               if sexChar == 'm' then
                    skin = uniforms[jobGrade+1]
                    table.insert(skin, sex)
                    skin.sex = 0
               else
                    skin = uniformsF[jobGrade+1]
                    table.insert(skin, sex)
                    skin.sex = 1
               end

               TriggerClientEvent('yp_police:changeUniform', src, skin)
          end)

end)

RegisterServerEvent('yp_police:getPlainSkin')
AddEventHandler('yp_police:getPlainSkin', function()
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)
     MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
               ['@identifier'] = xPlayer.identifier }, 
          function(result)
               local skin = json.decode(result[1].skin)
               TriggerClientEvent('yp_police:outUniform', src, skin)
          end)
end)

RegisterServerEvent('yp_police:buyMeds')
AddEventHandler('yp_police:buyMeds', function(item, cost)
     local src = source
     local xPlayer = ESX.GetPlayerFromId(src)
     --Charge the city
     TriggerEvent('esx_addonaccount:getSharedAccount', 'society_city', function(account)
          account.removeMoney(cost)
     end)

     --Give The weapon
     xPlayer.addInventoryItem(item, 1)
end)

RegisterServerEvent('yp_police:hirePlayer')
AddEventHandler('yp_police:hirePlayer', function(id, grade)
     local xPlayer = ESX.GetPlayerFromId(id)
     xPlayer.setJob('police', grade)
     TriggerClientEvent('yp_police:getHired', id)
     if grade == 8 then
          TriggerClientEvent('yp_police:makeBoss', id)
     end
end)

RegisterServerEvent('yp_police:getRegistration')
AddEventHandler('yp_police:getRegistration', function(plate)
     local src = source
     MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate',{
     ['@plate'] = plate},
     function(result)
          if result[1] ~= nil then
               TriggerEvent('yp_police:getOwnerFromId', result[1].owner, src)
          else
               TriggerClientEvent('yp_police:showPlayerName', src, 'Unknown')
          end
          
     end)
end)

RegisterServerEvent('yp_police:getOwnerFromId')
AddEventHandler('yp_police:getOwnerFromId', function(id, src)
     MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
     ['@identifier'] = id},
     function(result)
          local name = result[1].firstname .. ' ' .. result[1].lastname
          TriggerClientEvent('yp_police:showPlayerName', src, name)
     end)
end)

RegisterServerEvent('yp_police:sendLocation')
AddEventHandler('yp_police:sendLocation', function(player, src)
     local players = cops
     for i, v in pairs(players) do
          MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {['@identifier'] = ESX.GetPlayerFromId(src).identifier},
               function(result)
                    local name = result[1].firstname .. ' ' .. result[1].lastname --get players name that went on duty
                    TriggerClientEvent('yp_police:recieveLocation', i, player, name)
               end)           
     end
end)

RegisterServerEvent('yp_police:onDuty')
AddEventHandler('yp_police:onDuty', function(player)
     numCops = numCops + 1
     cops[source] = player
     TriggerEvent('yp_police:sendLocation', player, source)
     local src = source
     for i, v in pairs(cops) do--Get the locations of all the other cops on duty
          MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {['@identifier'] = ESX.GetPlayerFromId(i).identifier},
               function(result)
                    local name = result[1].firstname .. ' ' .. result[1].lastname --get players name that went on duty
                    TriggerClientEvent('yp_police:recieveLocation', src, v, name)
               end)
     end
end)

RegisterServerEvent('yp_police:offDuty')
AddEventHandler('yp_police:offDuty', function(player)
     numCops = numCops - 1
     cops[source] = nil
     for i, v in pairs(cops) do
          TriggerClientEvent('yp_police:removeCop', i, player)
          TriggerClientEvent('yp_police:removeCop', source, v)
     end
end)

RegisterServerEvent('yp_police:getLocations')
AddEventHandler('yp_police:getLocations', function()
     for i, v in pairs(cops) do
          TriggerClientEvent('yp_police:recieveLocation', source, v.player, v.name)
     end
end)

AddEventHandler('playerDropped', function(reason)
     if cops[source] then
          cops[source] = nil
          numCops = numCops - 1
     end
end)
