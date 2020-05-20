--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

local lawbook = {}

function calcDistance(str1, str2)
    local distance = 0

    matrix = {}

    for i = 0, #str1, 1 do
        matrix[i] = {}
        matrix[i][0] = i
    end

    for i = 0, #str2, 1 do
        matrix[0][i] = i
    end
    
    for i = 1, #str1, 1 do
        for j = 1, #str2, 1 do
            local cost = 0
            if (string.lower(string.sub(str1, i, i)) ~= string.lower(string.sub(str2, j, j))) then
                cost = 1
            end

            local min
            local a = matrix[i-1][j] + 1
            local b = matrix[i][j-1] + 1
            local c = matrix[i-1][j-1] + cost
            min = a

            if min > b then min = b end
            if min > c then min = c end

            matrix[i][j] = min
        end
    end

    distance = matrix[#str1][#str2]
    return distance
end

function initRecord(identifier)
    local record = {}

    for i, v in pairs(lawbook) do
        record[v.code] = 0
    end

    MySQL.Async.execute('INSERT INTO user_crimes (identifier, record, felon, dmvpoints) VALUES(@id, @lawbook, 0, 0)', {['@id'] = identifier, ['@lawbook'] = json.encode(record)},function() end)
end

AddEventHandler('onMySQLReady', function()
    MySQL.Async.fetchAll('SELECT * FROM lawbook', {}, 
    function(results)
        lawbook = results
    end)
end)

RegisterServerEvent('yp_cad:getLawbook')
AddEventHandler('yp_cad:getLawbook', function()
    print(lawbook)
    TriggerClientEvent('yp_cad:storeLawbook', source, lawbook)
    local identifiers = GetPlayerIdentifiers(source)
    local steam

    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steam = v
            break
        end
    end

    MySQL.Async.fetchAll('SELECT * FROM user_crimes WHERE identifier = @id', {['@id'] = steam},
        function(results)
            if not results[1] then
                initRecord(steam)
            end
        end)
end)

RegisterServerEvent('yp_cad:findPlayerInfo')
AddEventHandler('yp_cad:findPlayerInfo', function(name, type)
    local src = source
    local players = {}
    local fetching = true
    local fname
    local lname
    if string.find(name, ' ') then
        fname = string.sub(name, 1, string.find(name, ' ')-1)
        lname = string.sub(name, string.find(name, ' ')+1)
    else
        fname = name
        lname = name
    end
    MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, dateofbirth, sex FROM users', {},
        function(results)
            for i = 1, #results, 1 do 
                local distanceF = calcDistance(fname, results[i].firstname)
                local distanceL = calcDistance(lname, results[i].lastname)
                if distanceF/#fname < 0.2 or distanceL/#lname < 0.2 then
                    table.insert(players, results[i])
                end
            end
            fetching = false
        end)

    while fetching do
        Wait(0)
    end
    
    local count = 0

    for i, v in ipairs(players) do
        MySQL.Async.fetchAll('SELECT record, felon, dmvpoints FROM user_crimes WHERE identifier = @id', {['@id'] = v.identifier},
            function(results)
                if results[1] then
                    players[i].dmv = results[1].dmvpoints
                    players[i].record = results[1].record
                    players[i].felon = results[1].felon
                end
                count = count + 1
            end)
    end

    while count < #players do
        Wait(0)
    end

    TriggerClientEvent('yp_cad:getPlayerInfo', src, players, type)
end)

RegisterServerEvent('yp_cad:updateRecords')
AddEventHandler('yp_cad:updateRecords', function(id, data)
    local charges = json.decode(data)
    local record = {}
    local fetching = true
    MySQL.Async.fetchAll('SELECT record FROM user_crimes WHERE identifier = @id', {['@id'] = id},
        function(results)
            record = json.decode(results[1].record)
            --print(results[1].record)
            fetching = false
        end)

    while fetching do
        Wait(0)
    end

    for i, v in pairs(record) do
        if (charges[i]) then
            print(i .. ' ' .. v .. ' + ' .. charges[i])
            record[i] = v + charges[i]
        end
    end

    --print(json.encode(record))

    MySQL.Async.execute('UPDATE user_crimes SET record = @rec WHERE identifier = @id', {['@rec'] = json.encode(record), ['@id'] = id}, function()end)

end)

RegisterCommand('getlaw', function(source, args)
    MySQL.Async.fetchAll('SELECT * FROM lawbook', {}, 
    function(results)
        lawbook = results
    end)
end)