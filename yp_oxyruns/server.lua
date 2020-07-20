local ESX = nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('yp_oxyruns:addoxy')
AddEventHandler('yp_oxyruns:addoxy', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('oxy', 20)
 end)

RegisterServerEvent('yp_oxyruns:checkitem')
AddEventHandler('yp_oxyruns:checkitem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem('oxy').count <= 30 then
    	xPlayer.addInventoryItem('oxy', 20)	
        TriggerClientEvent('Bolls', source)
    elseif xPlayer.getInventoryItem('oxy').count >= 31 then
    	TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text ='You have too much Oxy', length = 5000})
    end
 end)


RegisterServerEvent('yp_oxyruns:sellOxy')
   AddEventHandler('yp_oxyruns:sellOxy', function(index)
    local xPlayer = ESX.GetPlayerFromId(source)
    local oxycount = math.random (1, 3)
    local moneycount = math.random (300, 500)
    local money = moneycount*oxycount
    if xPlayer.getInventoryItem('oxy').count >= oxycount then
        xPlayer.removeInventoryItem('oxy', oxycount)
        xPlayer.addMoney(money)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text ='You got ' .. money, length = 5000})
        TriggerClientEvent('removePepega', source, index)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text ='You do not have enough Oxy', length = 5000})
    end
end)


RegisterServerEvent('yp_oxyruns:cooldown')
AddEventHandler('yp_oxyruns:cooldown', function()
    TriggerClientEvent('yp_oxyruns:client:cooldown', -1)
end)