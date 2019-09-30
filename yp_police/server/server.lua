--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Functions
function resultToSkin(sqlString)
     --Take result string of skin components and turn it into a table using substring methods
     local tempString = sqlString
     local skin = {chain_2 = 0, mask_2 = 0, hair_1 = 0, glasses_2 = 0, watches_2 = 0, eyebrows_3 = 0, bproof_1 = 0, hair_2 = 0, hair_color_1 = 0, tshirt_1 = 0, decals_2 = 0, 
     pants_1 = 0, eyebrows_2 = 0, tshirt_2 = 0, face = 0, mask_1 = 0, bracelets_1 = 0, torso_1 = 0, lipstick_2 = 0, sun_2 = 0, bodyb_1 = 0, sex = 0, beard_1 = 0, makeup_3 = 0,
     skin = 0, sun_1 = 0, blemishes_2 = 0, eyebrows_1 = 0, chest_1 = 0, glasses_1 = 0, shoes_2 = 0, torso_2 = 0, arms_2 = 0, hair_color_2 = 0, arms = 0, blush_3 = 0, bodyb_2 = 0,
     bracelets_2 = 0, watches_1 = 0, eyebrows_4 = 0, makeup_1 = 0, helmet_1 = 0, age_2 = 0, blush_2 = 0, beard_2 = 0, beard_3 = 0, shoes_1 = 0, age_1 = 0, makeup_4 = 0, chain_1 = 0,
     bags_2 = 0, beard_4 = 0, ears_1 = 0, complexion_2 = 0, decals_1 = 0, bproof_2 = 0, bags_1 = 0, lipstick_4 = 0, moles_2 = 0, blemishes_1 = 0, chest_2 = 0, lipstick_1 = 0, 
     helmet_2 = 0, ears_2 = 0, moles_1 = 0, pants_2 = 0, eyecolor = 0, chest_3 = 0, makeup_2 = 0, complexion_1 = 0, blush_1 = 0}

     local startInd = string.find(tempString, '"')
     local lastInd = string.find(tempString, '"', startInd+1)
     local elem = string.sub(tempString, startInd+1, lastInd-1)
     local value = tonumber(string.sub(tempString, string.find(tempString, ':')+1, string.find(tempString, ',')-1))

     while (string.find(tempString, ',') ~= nil) do
          tempString = string.sub(tempString, string.find(tempString, ',')+1, string.len(tempString))
          
          if elem == 'chain_2' then
               skin.chain_2 = value
          elseif elem == 'mask_2' then
               skin.mask_2 = value
          elseif elem == 'hair_1' then
               skin.hair_1 = value
          elseif elem == 'glasses_2' then
               skin.glasses_2 = value
          elseif elem == 'watches_2' then
               skin.watches_2 = value
          elseif elem == 'eyebrows_3' then
               skin.eyebrows_3 = value
          elseif elem == 'bproof_1' then
               skin.bproof_1 = value
          elseif elem == 'hair_2' then
               skin.hair_2 = value
          elseif elem == 'hair_color_1' then
               skin.hair_color_1 = value
          elseif elem == 'tshirt_1' then
               skin.tshirt_1 = value
          elseif elem == 'decals_2' then
               skin.decals_2 = value
          elseif elem == 'pants_1' then
               skin.pants_1 = value
          elseif elem == 'eyebrows_2' then
               skin.eyebrows_2 = value
          elseif elem == 'tshirt_2' then
               skin.tshirt_2 = value
          elseif elem == 'face' then
               skin.face = value
          elseif elem == 'mask_1' then
               skin.mask_1 = value
          elseif elem == 'bracelets_1' then
               skin.bracelets_1 = value
          elseif elem == 'torso_1' then
               skin.torso_1 = value
          elseif elem == 'lipstick_2' then
               skin.lipstick_2 = value
          elseif elem == 'sun_2' then
               skin.sun_2 = value
          elseif elem == 'bodyb_1' then
               skin.bodyb_1 = value
          elseif elem == 'sex' then
               skin.sex = value
          elseif elem == 'beard_1' then
               skin.beard_1 = value
          elseif elem == 'makeup_3' then
               skin.makeup_3 = value
          elseif elem == 'skin' then
               skin.skin = value
          elseif elem == 'sun_1' then
               skin.sun_1 = value
          elseif elem == 'blemishes_2' then
               skin.blemishes_2 = value
          elseif elem == 'eyebrows_2' then
               skin.eyebrows_2 = value
          elseif elem == 'chest_1' then
               skin.chest_1 = value
          elseif elem == 'glasses_1' then
               skin.glasses_1 = value
          elseif elem == 'shoes_2' then
               skin.shoes_2 = value
          elseif elem == 'torso_2' then
               skin.torso_2 = value
          elseif elem == 'arms_2' then
               skin.arms_2 = value
          elseif elem == 'hair_color_2' then
               skin.hair_color_2 = value
          elseif elem == 'arms' then
               skin.arms = value
          elseif elem == 'blush_3' then
               skin.blush_3 = value
          elseif elem == 'bodyb_2' then
               skin.bodyb_2 = value
          elseif elem == 'bracelets_2' then
               skin.bracelets_2 = value
          elseif elem == 'watches_1' then
               skin.watches_1 = value
          elseif elem == 'eyebrows_4' then
               skin.eyebrows_4 = value
          elseif elem == 'makeup_1' then
               skin.makeup_1 = value
          elseif elem == 'helmet_1' then
               skin.helmet_1 = value
          elseif elem == 'age_2' then
               skin.age_2 = value
          elseif elem == 'blush_2' then
               skin.blush_2 = value
          elseif elem == 'beard_2' then
               skin.beard_2 = value
          elseif elem == 'beard_3' then
               skin.beard_3 = value
          elseif elem == 'shoes_1' then
               skin.shoes_1 = value
          elseif elem == 'age_1' then
               skin.age_1 = value
          elseif elem == 'makeup_4' then
               skin.makeup_4 = value
          elseif elem == 'chain_1' then
               skin.chain_1 = value
          elseif elem == 'bags_2' then
               skin.bags_2 = value
          elseif elem == 'beard_4' then
               skin.beard_4 = value
          elseif elem == 'ears_1' then
               skin.ears_1 = value
          elseif elem == 'complexion_2' then
               skin.complexion_2 = value
          elseif elem == 'decals_1' then
               skin.decals_1 = value
          elseif elem == 'bproof_2' then
               skin.bproof_2 = value
          elseif elem == 'bags_1' then
               skin.bags_1 = value
          elseif elem == 'lipstick_4' then
               skin.lipstick_4 = value
          elseif elem == 'moles_2' then
               skin.moles_2 = value
          elseif elem == 'blemishes_1' then
               skin.blemishes_1 = value
          elseif elem == 'chest_2' then
               skin.chest_2 = value
          elseif elem == 'lipstick_1' then
               skin.lipstick_1 = value
          elseif elem == 'helmet_2' then
               skin.helmet_2 = value
          elseif elem == 'ears_2' then
               skin.ears_2 = value
          elseif elem == 'moles_1' then
               skin.moles_1 = value
          elseif elem == 'pants_2' then
               skin.pants_2 = value
          elseif elem == 'eyecolor' then
               skin.eyecolor = value
          elseif elem == 'chest_3' then
               skin.chest_3 = value
          elseif elem == 'makeup_2' then
               skin.makeup_2 = value
          elseif elem == 'complexion_1' then
               skin.complexion_1 = value
          elseif elem == 'blush_1' then
               skin.blush_1 = value
          else
               print("Error: Failed to assign component value")
          end


          startInd = string.find(tempString, '"')
          lastInd = string.find(tempString, '"', startInd+1)
          elem = string.sub(tempString, startInd+1, lastInd-1)
          if string.find(tempString, ',') ~= nil then
               value = tonumber(string.sub(tempString, string.find(tempString, ':')+1, string.find(tempString, ',')-1))
          else
               value = tonumber(string.sub(tempString, string.find(tempString, ':')+1, string.find(tempString, '}')-1))
          end

     end
     return skin
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
               local skin = resultToSkin(result[1].skin)
               TriggerClientEvent('yp_police:outUniform', src, skin)
          end)
end)

RegisterServerEvent('yp_police:toggleDuty')
AddEventHandler('yp_police:toggleDuty', function(state) 
     local xPlayer = ESX.GetPlayerFromId(source)
     if xPlayer.job.name == 'police' then
          if state then
               TriggerClientEvent('yp_police:offDuty', source)
          else
               TriggerClientEvent('yp_police:onDuty', source)
          end
     end
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


RegisterCommand('onduty', function(source, args)
     local xPlayer = ESX.GetPlayerFromId(source)
     if xPlayer.job.name == 'police' then
          TriggerClientEvent('yp_police:onDuty', source)
     end
end)

RegisterCommand('offduty', function(source, args)
     local xPlayer = ESX.GetPlayerFromId(source)
     if xPlayer.job.name == 'police' then
          TriggerClientEvent('yp_police:offDuty', source)
     end
end)
