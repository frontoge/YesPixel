--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--
ESX = nil

local YPlayers = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function initializeOrgs(id)
  local defaultOrgs = {}
  local fetching = true
  MySQL.Async.fetchAll('SELECT name FROM organizations', {},
    function(results)
      for i, v in ipairs(results) do
        defaultOrgs[v.name] = 0
      end
      fetching = false
    end)

  while fetching do
    Citizen.Wait(0)
  end

  MySQL.Async.execute('INSERT INTO user_organizations (identifier, orgs) VALUES (@identifier, @orgs)', {['@identifier'] = id, ['@orgs'] = json.encode(defaultOrgs)},function(results)end)
  return defaultOrgs
end

function getPlayers()
  return YPlayers
end

function getPlayerBySource(src)
  return YPlayers[src]
end

RegisterCommand('setorg', function(source, args)
  TriggerClientEvent('yp_base:sendOrgUpdate', args[1], args[2], args[3], source)
end, true)

RegisterCommand('orgs', function(source, args)
  for i, v in pairs(YPlayers[source].orgs) do
    print(i .. ": " .. v)
  end
end)

RegisterServerEvent('yp_base:setOrg')
AddEventHandler('yp_base:setOrg', function(org, level, sender)
  if YPlayers[source].orgs[org] ~= nil then
    YPlayers[source].orgs[org] = level
    MySQL.Async.execute('UPDATE user_organizations SET orgs = @orgs WHERE identifier = @identifier', {['@orgs'] = json.encode(YPlayers[source].orgs), ['@identifier'] = YPlayers[source].identifier},
      function() end)
  else
    TriggerClientEvent("chat:addMessage", sender, {color = {255, 0, 0}, multiline = true, args = {"System:", org .. ' is not a valid organization'}})
  end
end)

RegisterServerEvent('yp_base:loadPlayerData')
AddEventHandler('yp_base:loadPlayerData', function()
  local src = source
  Citizen.CreateThread(function()
  	local identifier = GetPlayerIdentifier(src, 0)
    local data = {}

    local fetching = true
  	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = identifier}, --GetPlayerData
  		function(results)
  			if results[1] ~= nil then
          data = results[1]
  			end
        fetching = false
  		end)

    while fetching do
      Citizen.Wait(0)
    end
    
    fetching = true

    MySQL.Async.fetchAll('SELECT orgs FROM user_organizations WHERE identifier = @identifier', {['@identifier'] = identifier},
      function(results)
        print(results[1])
        if results[1] ~= nil then
          data.orgs = json.decode(results[1].orgs)
        else
          data.orgs = initializeOrgs(identifier)
        end
        fetching = false
      end)
    
    while fetching do
      Citizen.Wait(0)
    end

    YPlayers[src] = data
    TriggerClientEvent('yp_base:setPlayerData', src, data)
  end)
end)

RegisterServerEvent('yp_base:playerReady')
AddEventHandler('yp_base:playerReady', function()
  local src = source
  TriggerClientEvent('yp_base:disableHPRegen', src)
  TriggerClientEvent('yp_base:ready', src)
  TriggerClientEvent('yp_swedbank:playerReady', src)
  TriggerClientEvent('yp_police:playerReady', src)
end)

RegisterServerEvent('yp_base:addItem')
AddEventHandler('yp_base:addItem', function(name, amount)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.addInventoryItem(name, amount)
end)

RegisterServerEvent('yp_base:removeItem')
AddEventHandler('yp_base:removeItem', function(name, amount)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem(name, amount)
end)

RegisterServerEvent('yp_base:getPlayerJob')
AddEventHandler('yp_base:getPlayerJob', function(cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  TriggerClientEvent(cb, source, xPlayer.job.name)
end)

RegisterServerEvent('yp_base:payFee')
AddEventHandler('yp_base:payFee', function(fee)
  local xPlayer =ESX.GetPlayerFromId(source)
  xPlayer.removeAccountMoney('bank', fee)
end)

RegisterCommand('job', function(source, args)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local job = xPlayer.job.label
  TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You are currently employed as: ' .. job .. '.', length = 2500})
  
end, false)

RegisterCommand('cash', function(source, args)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(source)
  local cash = xPlayer.getMoney()
  TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You currently have $' .. cash .. ' in your wallet.', length = 2500})

end, false)

RegisterCommand('bank', function(source, args)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local bank = xPlayer.getBank()
  TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'You currently have $' .. bank .. ' in your bank.', length = 2500})

end, false)

--Move to yp_announce--

function restartAnnounce(d, h, m)
  local time = 60 - m
  TriggerClientEvent('chat:addMessage', -1, {color = {255, 0, 0}, multiline = true, args = {"Announcement:", "Server will restart in " .. time .. " minutes"}})
end

function kickAll(d, h, m)
	--Kick everyplayer
end

TriggerEvent('cron:runAt', 23, 30, restartAnnounce)
TriggerEvent('cron:runAt', 23, 45, restartAnnounce)
TriggerEvent('cron:runAt', 23, 50, restartAnnounce)
TriggerEvent('cron:runAt', 23, 55, restartAnnounce)
TriggerEvent('cron:runAt', 23, 59, kickAll)

TriggerEvent('cron:runAt', 15, 30, restartAnnounce)
TriggerEvent('cron:runAt', 15, 45, restartAnnounce)
TriggerEvent('cron:runAt', 15, 50, restartAnnounce)
TriggerEvent('cron:runAt', 15, 55, restartAnnounce)
TriggerEvent('cron:runAt', 15, 59, kickAll)

TriggerEvent('cron:runAt', 7, 30, restartAnnounce)
TriggerEvent('cron:runAt', 7, 45, restartAnnounce)
TriggerEvent('cron:runAt', 7, 50, restartAnnounce)
TriggerEvent('cron:runAt', 7, 55, restartAnnounce)
TriggerEvent('cron:runAt', 7, 59, kickAll)
