--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_base:playerReady')
AddEventHandler('yp_base:playerReady', function()
  local src = source
  TriggerClientEvent('yp_base:disableHPRegen', src)
  TriggerClientEvent('yp_bankrob:playerReady', src)
  TriggerClientEvent('yp_swedbank:playerReady', src)
  TriggerClientEvent('yp_police:playerReady', src)
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

