--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local robbers = {}
local cooldownMax = 2 * 60
local robberyCount = 0
local cooldowns = {
  { name = 'Flecca Legion Square', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Flecca Del Perro', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Flecca Great Ocean Hwy', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Blain County Savings', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Flecca Sandy Shores', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Flecca Vinewood.', cooldown = cooldownMax, onCooldown = false, robbed = false, drilling = {false, false, false, false, false}},
  { name = 'Flecca Hawick Ave', cooldown = cooldownMax, onCooldown = false, robbed = false}, drilling = {false, false, false, false, false}}

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Functions
function isRobber(id)
  for i, v in ipairs(robbers) do
    if v == id then
      return true
    end
  end
  return false
end

function startCooldown(bank)
  robbers = {}
  robberyCount = robberyCount - 1
  Citizen.CreateThread(function()
    cooldowns[bank].onCooldown = true
    while cooldowns[bank].cooldown > 0 do
      Citizen.Wait(1000)
      cooldowns[bank].cooldown = cooldowns[bank].cooldown - 1
    end
    cooldowns[bank].onCooldown = false
    cooldowns[bank].cooldown = cooldownMax
    cooldowns[bank].robbed = false
    TriggerClientEvent('yp_bankrob:resetClient', -1, bank)
  end)
end

--Server Events
RegisterServerEvent('yp_bankrob:startRob')
AddEventHandler('yp_bankrob:startRob', function(bankNum)
  local src = source
  local bank = cooldowns[bankNum]
  local xPlayer = ESX.GetPlayerFromId(src)
  if not bank.onCooldown then --If the bank is not on cooldown
    if robberyCount <= 0 then --If there are no banks being robbed already
      if xPlayer.getInventoryItem('brutedrive').count > 0 then --If you have a brute force drive
        TriggerClientEvent('yp_bankrob:startHack', src, bankNum) --Start the hack minigame
        TriggerEvent('yp_bankrob:tripAlarm', bankNum) --Trigger the alarm for police
        if not isRobber(src) then --If you arent a robber
          table.insert(robbers, src) --Become a robber
        end
      else --If you dont have a brute force drive
        TriggerEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a brute force drive', length = 2500})
      end
    elseif bank.robbed then -- There is a bank being robbed already but its this bank
      if xPlayer.getInventoryItem('brutedrive').count > 0 then --if you have a brute force drive
        TriggerClientEvent('yp_bankrob:startHack', src, bankNum) --Start the hack minigame
        if not isRobber(src) then --if you arent a robber become one
          table.insert(robbers, src)
        end 
      else --You dont have a brute force drive
        TriggerEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a brute force drive', length = 2500})
      end
    else --There is already a bank robbery in progress and it isnt this one
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There seems to be no power to the panel...', length = 2500})
    end
  else --The bank is on cooldown
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This bank has already been robbed, come back in ' .. bank.cooldown .. 's', length = 2500})
  end
end)    

RegisterServerEvent('yp_bankrob:tripAlarm')
AddEventHandler('yp_bankrob:tripAlarm', function(bank)
  local xPlayers = ESX.GetPlayers()
  for i = 1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    local job = xPlayer.job.name
    if job == 'police' or job == 'sheriff' then
      TriggerClientEvent('yp_bankrob:displayAlarm', xPlayers[i], bank)
      TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = cooldowns[bank].name .. ' is being robbed!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
    end
  end
  cooldowns[bank].robbed = true
  robberyCount = robberyCount +1
end)

RegisterServerEvent('yp_bankrob:startDrill')
AddEventHandler('yp_bankrob:startDrill', function(bank, drill)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if not isRobber(src) then
    table.insert(robbers, src)
  end
  if not cooldowns[bank].onCooldown then
    if xPlayer.getInventoryItem('drill').count > 0 then
      if not cooldowns[bank].drilling[drill] then
        xPlayer.removeInventoryItem('drill', 1)
        TriggerClientEvent('yp_bankrob:startDrilling', src, bank, drill)
        cooldowns[bank].drilling[drill] = true
      else
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'This box is already being drilled!', length = 2500})
      end
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You do not have a Drill!', length = 2500})
    end
  end
end)

RegisterServerEvent('yp_bankrob:leaveStore')
AddEventHandler('yp_bankrob:leaveStore', function(bank)
  local src = source 
  if isRobber(src) then
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
      local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
      local job = xPlayer.job.name
      if job == 'police' or job == 'sheriff' then
        TriggerClientEvent('yp_bankrob:killAlarm', xPlayers[i])
        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'The robbery at ' .. cooldowns[bank].name .. ' has been cancelled!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
      end
    end
    if not cooldowns[bank].onCooldown then
      startCooldown(bank)
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'Robbery has been cancelled', length = 2500})
    end
  end
end)

RegisterServerEvent('yp_bankrob:consumeDrive')
AddEventHandler('yp_bankrob:consumeDrive', function()
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.removeInventoryItem('brutedrive', 1)
end)

RegisterServerEvent('yp_bankrob:finishHack')
AddEventHandler('yp_bankrob:finishHack', function(bank)
  TriggerClientEvent('yp_bankrob:hackComplete', -1, bank)
end)

RegisterServerEvent('yp_bankrob:drillFinish')
AddEventHandler('yp_bankrob:drillFinish', function(bank, drillNum)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local payout = 0
  if cooldowns[bank].name == "Blaine County Savings" then
    payout = math.random(9000, 14000)
  else
    payout = math.random(6500, 11500)
  end
  xPlayer.addAccountMoney('black_money', payout)
  TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You got $'.. payout .. ' black money', length = 2500})
  TriggerClientEvent('yp_bankrob:drillDone', -1, bank, drillNum)
  
end)

RegisterServerEvent('yp_bankrob:stopDrilling')
AddEventHandler('yp_bankrob:stopDrilling', function(bank, drillNum)
  cooldowns[bank].drilling[drillNum] = false
end)