--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local beingRobbed = false
local onCooldown = false
local firstSell = true
local firstCase = true
local cooldownMax = 2 * 60 --Minutes until store is robbable
local cooldown = cooldownMax
local copMin = 1
local copsOn = 0
local casesBroken = 0
local robbers = {}
local vgPrice = 6000 --Price of one Valuable good
local rolexPrice = 300 --Price of a Rolex
local chainPrice = 150 -- Price of a goldchain
local ringPrice = 75 --Price of a ring

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Functions
function resetStore()
  robbers = {}
  casesBroken = 0
  firstCase = true
  copsOn = 0
  TriggerClientEvent('resetCases', -1)

end 
  
function doCooldown()
  onCooldown = true
  Citizen.CreateThread(function()
    while cooldown > 0 do
      cooldown = cooldown - 1
      Citizen.Wait(1000)
    end
    cooldown = cooldownMax
    onCooldown = false
    resetStore()
  end)
end

function isRobber(playerid)
  for i = 1, #robbers, 1 do
    if robbers[i] == playerid then
      return true
    end
  end
  return false
end

function hasJewelry(xPlayer)
  if xPlayer.getInventoryItem('valuablegoods').count > 0 or xPlayer.getInventoryItem('rolex').count > 0 or xPlayer.getInventoryItem('goldchain').count > 0 or xPlayer.getInventoryItem('ring').count > 0 then
    return true
  else
    return false
  end
end


function robberyEnd()
  for i = 1, #robbers, 1 do
    TriggerClientEvent('mythic_notify:client:SendAlert', robbers[i], { type = 'success', text = 'You robbed the jewelry!', length = 2500})
  end
  beingRobbed = false
  local xPlayers = ESX.GetPlayers()
  for i = 1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
      TriggerClientEvent('killAlarm', xPlayers[i]) 
      TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'The Robbery at the jewelry has been cancelled.', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
    end
  end
  
  doCooldown()
end


RegisterServerEvent('yp_jewelry:startCase')
AddEventHandler('yp_jewelry:startCase', function(caseNumber)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(source)
  local case = caseNumber
  
  if firstCase then
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local player = ESX.GetPlayerFromId(xPlayers[i])
		if player.job.name == 'police' then
			copsOn = copsOn + 1
		end
	end
  end
  
  if copsOn >= copMin then
    if not onCooldown then
      TriggerClientEvent('breakCase', src, case)
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'The jewelry has already been robbed, come back in ' .. cooldown .. 's' , length = 2500})
    end
  else
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There needs to be at least ' .. copMin .. ' cops on to rob the jewelry', length = 2500})
  end
end)

RegisterServerEvent('robCase')
AddEventHandler('robCase', function(caseNumber, weaponClass)
  local src = source
  if not isRobber(src) then
    table.insert(robbers, src)
  end
  local xPlayer = ESX.GetPlayerFromId(src)
  local itemChoice = math.random(1,100)
  
  --Give the Player items based on weapon class
  if weaponClass == 0 then
    if(itemChoice <= 5) then --5% chance of Rolex
      xPlayer.addInventoryItem('rolex', math.random(1, 5))--Amount of rolex
    elseif(itemChoice <= 20) then -- 15% of Goldchain
      xPlayer.addInventoryItem('goldchain', math.random(5, 10))--Amount of goldchain
    elseif itemChoice <= 50 then -- 25% of Rings
      xPlayer.addInventoryItem('ring', math.random(5,15))--Amount of rings
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There was nothing in the case!', length = 2500})
    end
  elseif weaponClass == 1 then
    if(itemChoice <= 2) then --2% chance of VG
      xPlayer.addInventoryItem('valuablegoods', math.random(1, 3))--Amount of VG
    elseif(itemChoice <= 12) then --10% of Rolex
      xPlayer.addInventoryItem('rolex', math.random(5, 10))--Amount of rolex
    elseif(itemChoice <= 32) then -- 20% of Goldchain
      xPlayer.addInventoryItem('goldchain', math.random(5, 20))--Amount of goldchain
    elseif itemChoice <= 60 then -- 28% of Rings
      xPlayer.addInventoryItem('ring', math.random(5,25))--Amount of rings
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There was nothing in the case!', length = 2500})
    end
  elseif weaponClass == 2 then
    if(itemChoice <= 5) then --5% chance of VG
      xPlayer.addInventoryItem('valuablegoods', math.random(1, 4))--Amount of VG
    elseif(itemChoice <= 30) then --25% of Rolex
      xPlayer.addInventoryItem('rolex', math.random(10, 15))--Amount of rolex
    elseif itemChoice <= 70 then -- 40% of Goldchain
      xPlayer.addInventoryItem('goldchain', math.random(10, 25))--Amount of goldchain
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There was nothing in the case!', length = 2500})
    end
  elseif weaponClass == 3 then
    if(itemChoice <= 7) then --7% chance of VG
      xPlayer.addInventoryItem('valuablegoods', math.random(1, 4))--Amount of VG
    elseif itemChoice <= 67 then --60% of Rolex
      xPlayer.addInventoryItem('rolex', math.random(15, 20))--Amount of rolex
    elseif itemChoice <= 80 then -- 13% of Goldchain
      xPlayer.addInventoryItem('goldchain', math.random(10, 25))--Amount of goldchain+
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'There was nothing in the case!', length = 2500})
    end
  end
  
  TriggerClientEvent('toggleCase', -1, caseNumber)
  casesBroken = casesBroken + 1
  if casesBroken == 20 then
    robberyEnd()
  end
end)

RegisterServerEvent('tripAlarm')
AddEventHandler('tripAlarm', function()
  local pos = {x = -627.8656, y = -235.8835, z = 38.0570}
  if not beingRobbed then
    beingRobbed = true
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
      local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
      if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayers[i], { type = 'inform', text = 'The jewelry is being robbed!', length = 3000, style = {['background-color'] = '#eb8b0e', ['color'] = '#000000'}})
        TriggerClientEvent('alarmBlip', xPlayers[i], pos)
      end
    end
  end
end)

RegisterServerEvent('leaveStore')
AddEventHandler('leaveStore', function()
    if beingRobbed then
      if isRobber(source) then
        robberyEnd()
      end
    end
end)

RegisterServerEvent('sellJewelry')
AddEventHandler('sellJewelry', function()
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local totalSales = 0
  
  if hasJewelry(xPlayer) then
    Citizen.CreateThread(function()
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Jewelry sale in progress', length = 2500})
      while hasJewelry(xPlayer) do
        --Sell VG's
        if xPlayer.getInventoryItem('valuablegoods').count > 0 then
          xPlayer.removeInventoryItem('valuablegoods', 1)
          xPlayer.addMoney(vgPrice)
          totalSales = totalSales + vgPrice
        end
        --Sell Rolex
        if xPlayer.getInventoryItem('rolex').count > 0 then
          if xPlayer.getInventoryItem('rolex').count >=5 then
            xPlayer.removeInventoryItem('rolex', 5)
            xPlayer.addMoney(rolexPrice * 5)
            totalSales = totalSales + rolexPrice * 5
          else
            xPlayer.removeInventoryItem('rolex', xPlayer.getInventoryItem('rolex').count)
            xPlayer.addMoney(rolexPrice * xPlayer.getInventoryItem('rolex').count)
            totalSales = totalSales + rolexPrice * xPlayer.getInventoryItem('rolex').count
          end
        end
        --Sell Goldchains
        if xPlayer.getInventoryItem('goldchain').count > 0 then
          jewelryToSell = true
          if xPlayer.getInventoryItem('goldchain').count >=5 then
            xPlayer.removeInventoryItem('goldchain', 5)
            xPlayer.addMoney(chainPrice * 5)
            totalSales = totalSales + chainPrice * 5
          else
            xPlayer.removeInventoryItem('goldchain', xPlayer.getInventoryItem('goldchain').count)
            xPlayer.addMoney(chainPrice * xPlayer.getInventoryItem('goldchain').count)
            totalSales = totalSales + chainPrice * xPlayer.getInventoryItem('goldchain').count
          end
        end
        --Sell Rings
        if xPlayer.getInventoryItem('ring').count > 0 then
          jewelryToSell = true
          if xPlayer.getInventoryItem('ring').count >=10 then
            xPlayer.removeInventoryItem('ring', 10)
            xPlayer.addMoney(ringPrice * 10)
            totalSales = totalSales + ringPrice * 10
          else
            xPlayer.removeInventoryItem('ring', xPlayer.getInventoryItem('ring').count)
            xPlayer.addMoney(ringPrice * xPlayer.getInventoryItem('ring').count)
            totalSales = totalSales + ringPrice * xPlayer.getInventoryItem('ring').count
          end
        end
        Citizen.Wait(500)
      end
      TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = 'You sold jewelry for $' .. totalSales .. '!', length = 2500})
    end)
  end
end)

