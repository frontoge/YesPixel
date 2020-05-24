local houses = {} --Holds all the info from the database retrieved at the start of the script
local loaded = {} --Holds interiors that are currently loaded to prevent duplicate rendering
local modified = false --State of the data in houses table, true if modified

local DEBUG = true

---Framework---
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

---*********---


--Init
AddEventHandler('onMySQLReady', function()
    MySQL.Async.fetchAll('SELECT * FROM houses', {}, function(results)
        for i, v in ipairs(results) do
            houses[i] = v
            houses[i].front = json.decode(houses[i].front)
            houses[i].back = json.decode(houses[i].back)
            houses[i].inv = json.decode(houses[i].inv)
            loaded[i] = 0
        end
    end)
end)

--Events
RegisterServerEvent('yp_housing:requestHouseData')
AddEventHandler('yp_housing:requestHouseData', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('yp_housing:receiveHouseData', source, houses, xPlayer.getIdentifier())
end)

RegisterServerEvent('yp_housing:requestInterior')
AddEventHandler('yp_housing:requestInterior', function(num, pos, door)
    local load = true
    if loaded[num] > 0 then load = false end
    loaded[num] = loaded[num] + 1
    TriggerClientEvent('yp_housing:enterHouse', source, pos, door, load)
end)

RegisterServerEvent('yp_housing:leaveHouse')
AddEventHandler('yp_housing:leaveHouse', function(num)
    loaded[num] = loaded[num] - 1
    local remove = false
    if loaded[num] < 1 then
        remove = true
    end
    TriggerClientEvent('yp_housing:exitHouse', source, remove)
end)

RegisterServerEvent('yp_housing:getPlayerInv')
AddEventHandler('yp_housing:getPlayerInv', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {}
    local items = xPlayer.getInventory()
    local weapons = xPlayer.getLoadout()
    local cash = xPlayer.getMoney()

    for i, v in ipairs(items) do--Add items to the list
        if v.count > 0 then
            local temp = {label = v.label .. '(x ' .. v.count .. ')', name = v.name, value = v.count}
            table.insert(data, temp)
        end
    end

    for i, v in pairs(weapons) do--Add weapons to the list
        local temp = v
        table.remove(temp, ammo)
        temp.value = 1
        temp.label = v.name .. ' (x' .. temp.value .. ')'
        table.insert(data, temp)
    end

    table.insert(data, {label = "Cash" .. ' ($' .. cash .. ')', name = 'cash', value = cash})

    TriggerClientEvent('yp_housing:depositItem', source, data)
end)

RegisterServerEvent('yp_housing:getHouseInv')
AddEventHandler('yp_housing:getHouseInv', function(houseNum)
    local xPlayer = ESX.GetPlayerFromId(source)
    local inv = {}
    local label
    for i, v in ipairs(houses[houseNum].inv) do
        if string.find(v.name, 'WEAPON') or string.find(v.name, 'GADGET') then
            label = v.name .. ' (x' .. v.value .. ')'
        elseif v.name == 'cash' then
            label = 'Cash $' .. v.value
        else
            label = xPlayer.getInventoryItem(v.name).label .. ' (x' .. v.value .. ')'
        end
        table.insert(inv, {label = label, name = v.name, value = v.value})
    end
    TriggerClientEvent('yp_housing:pullItem', source, inv)
end)

RegisterServerEvent('yp_housing:addItemToHouse')
AddEventHandler('yp_housing:addItemToHouse', function(houseNum, itemData)
    local found = false
    local xPlayer = ESX.GetPlayerFromId(source)--Load player data
    for i, v in pairs(houses[houseNum].inv) do
        if v.name == itemData.name then
            v.value = v.value + itemData.value --Add item to house inv
            found = true
            if string.find(itemData.name, 'WEAPON') or string.find(itemData.name, 'GADGET') then --If its a weapon
                xPlayer.removeWeapon(itemData.name)
            elseif itemData.name == 'cash' then
                xPlayer.removeMoney(itemData.value) --if its cash
            else
                xPlayer.removeInventoryItem(itemData.name, itemData.value) --if its an item
            end
            break
        end
    end
    if not found then --If the item was not in the house
        table.insert(houses[houseNum].inv, {name = itemData.name, value = itemData.value}) --Add item to house in a new slot

        if string.find(itemData.name, 'WEAPON') or string.find(itemData.name, 'GADGET') then --Take item from player
            xPlayer.removeWeapon(itemData.name)
            found = true
        elseif itemData.name == 'cash' then
            xPlayer.removeMoney(itemData.value)
            found = true
        else
            xPlayer.removeInventoryItem(itemData.name, itemData.value)
            found = true
        end
    end
    modified = true
end)

RegisterServerEvent('yp_housing:removeItemFromHouse')
AddEventHandler('yp_housing:removeItemFromHouse', function(houseNum, itemData)
    local xPlayer = ESX.GetPlayerFromId(source)--Load player data
    for i, v in pairs(houses[houseNum].inv) do
        if v.name == itemData.name then
            v.value = v.value - itemData.value --Remove item to house inv
            if string.find(itemData.name, 'WEAPON') or string.find(itemData.name, 'GADGET') then --If its a weapon
                if itemData.value > 1 then --Only add one item if its a weapon
                    v.value = v.value + itemData.value - 1
                end
                xPlayer.addWeapon(itemData.name)
            elseif itemData.name == 'cash' then
                xPlayer.addMoney(itemData.value) --if its cash
            else
                xPlayer.addInventoryItem(itemData.name, itemData.value) --if its an item
            end
            if v.value <= 0 then
                table.remove(houses[houseNum].inv, i)
            end
            break
        end
    end
    modified = true
end)

RegisterServerEvent('yp_housing:sellHouse')
AddEventHandler('yp_housing:sellHouse', function(target, houseId)
    local xPlayer = ESX.GetPlayerFromId(source) --Person selling the house
    if xPlayer.job.name == 'realtor' then
        local targetPlayer = ESX.GetPlayerFromId(target) --Get target player
        local amount = houses[houseId].price
        TriggerClientEvent('yp_housing:sendHouseBill', source, target, amount * 0.95)
        xPlayer.addAccountMoney('bank', amount * 0.05)
        houses[houseId].owner = targetPlayer.getIdentifier() --Set house owner
        TriggerClientEvent('yp_housing:getHouse', target, houseId)
        modified = true
        TriggerClientEvent('yp_housing:showVacantHouses', source)
    end
end)

RegisterServerEvent('yp_housing:setHouseLockCode')
AddEventHandler('yp_housing:setHouseLockCode', function(houseId, code)
    houses[houseId].code = code
    modified = true
    TriggerClientEvent('yp_housing:updateHouse', -1, houseId, houses[houseId])
end)

RegisterServerEvent('yp_housing:toggleLock')
AddEventHandler('yp_housing:toggleLock', function(houseId)
    houses[houseId].locked = (houses[houseId].locked + 1) % 2
    modified = true
    TriggerClientEvent('yp_housing:updateHouse', -1, houseId, houses[houseId])
end)

--Commands
RegisterCommand('showHouses', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= 'realtor' then return end

    TriggerClientEvent('yp_housing:showVacantHouses', source)
end)

RegisterCommand('hideHouses', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= 'realtor' then return end

    TriggerClientEvent('yp_housing:hideVacantHouses', source)
end)

--Threads
Citizen.CreateThread(function() --Push the houses into the Database
    while true do
        if modified then
            for i, v in ipairs(houses) do
                local values = {}
                for column, value in pairs(v) do
                    values['@' .. column] = value
                end
                values['@front'] = json.encode(values['@front'])
                values['@back'] = json.encode(values['@back'])
                values['@inv'] = json.encode(values['@inv'])

                MySQL.Async.execute('UPDATE houses SET owner = @owner, model = @model, front = @front, back = @back, inv = @inv, locked = @locked, code = @code WHERE id = @id', values,
                function()  end)
            end
            modified = false
        end
        Citizen.Wait(1000)
    end
end)

--Dev Remove before release
if DEBUG then

    function refreshDB()
        MySQL.Async.fetchAll('SELECT * FROM houses', {}, function(results)
            for i, v in ipairs(results) do
                houses[i] = v
                houses[i].front = json.decode(houses[i].front)
                if (houses[i].back) then
                    houses[i].back = json.decode(houses[i].back)
                end
                houses[i].inv = json.decode(houses[i].inv)
                loaded[i] = 0
            end
            local xPlayers = ESX.GetPlayers()
            for i = 1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                TriggerClientEvent('yp_housing:receiveHouseData', xPlayers[i], houses, xPlayer.getIdentifier())
            end
        end)
    end

    RegisterServerEvent('finishHouse')
    AddEventHandler('finishHouse', function(house)
        if house['@back'] and house['@garage'] then
            MySQL.Async.execute("INSERT INTO houses (model, front, back, inv, locked, price, garage) VALUES(@model, @front, @back, @inv, @locked, @price, @garage)", house, function()end)
        elseif house['@back'] then
            MySQL.Async.execute("INSERT INTO houses (model, front, back, inv, locked, price) VALUES(@model, @front, @back, @inv, @locked, @price)", house, function()end)
        elseif house['@garage'] then
            MySQL.Async.execute("INSERT INTO houses (model, front, inv, locked, price, garage) VALUES(@model, @front, @inv, @locked, @price, @garage)", house, function()end)
        else
            MySQL.Async.execute("INSERT INTO houses (model, front, inv, locked, price) VALUES(@model, @front, @inv, @locked, @price)", house, function()end)
        end
        refreshDB()
        
    end)

    RegisterCommand('getdb', function(source, args)
        refreshDB()
    end)

    RegisterCommand('getPlayer', function(source, args)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('addPlayer', source, xPlayer)
    end)
end
