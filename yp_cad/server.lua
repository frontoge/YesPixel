ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

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

function validPoints(dateStr)
    local oldDate = {} --Convert to table 
    oldDate.day = string.sub(dateStr, 1, string.find(dateStr, '/')-1) --Get the date
    oldDate.month = tonumber(string.sub(dateStr, #oldDate.day+2, string.find(dateStr, '/', #oldDate.day+2)-1)) --find the month
    oldDate.year = tonumber(string.sub(dateStr, -4))
    oldDate.day = tonumber(oldDate.day)

    --Calculate the number of days past
    local time = os.time()
    local oldTime = os.time{year = oldDate.year, month = oldDate.month, day = oldDate.day}

    if time - oldTime >= 1209600 then --If this charge was more than 14 days old ignore it
        return false 
    end
    return true
end

function getChargeFromCode(code)
    for i, v in pairs(lawbook) do
        if code == v.code then
            return v
        end
    end
end

AddEventHandler('onMySQLReady', function()
    MySQL.Async.fetchAll('SELECT * FROM lawbook', {}, 
    function(results)
        lawbook = results
    end)
end)

RegisterServerEvent('yp_cad:getLawbook')
AddEventHandler('yp_cad:getLawbook', function()
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
        players[i].record = {}
        players[i].points = 0
        players[i].felon = false

        MySQL.Async.fetchAll('SELECT charge, points, felony, date FROM criminal_records WHERE owner = @id', {['@id'] = v.identifier}, --Get the record of each player
            function(results)
                if results[1] then --If the user has a record
                    for index, value in ipairs(results) do
                        if validPoints(value.date) then
                            players[i].points = players[i].points + value.points--Add the points for this charge
                        end
                        if not players[i].felon and value.felony == 1 then
                            players[i].felon = true
                        end
                        table.insert(players[i].record, value.charge .. ' ' .. value.date) --Get the charge/Date
                    end
                end
                count = count + 1
            end)
    end

    while count < #players do --Wait for the SQL callbacks to finish
        Wait(0)
    end

    TriggerClientEvent('yp_cad:getPlayerInfo', src, players, type)
end)

RegisterServerEvent('yp_cad:updateRecords')
AddEventHandler('yp_cad:updateRecords', function(id, data)
    local chargeList = {}
    local chargesRaw = json.decode(data)
    for i, v in pairs(chargesRaw) do --For each charge
        if v > 0 then --If this charge was acutally filed
            --Format the charge for storage
            local charge = getChargeFromCode(i)--Get the charge info from the lawbook
            local date = os.date('*t') --Get the current date of the charge
            local values = {}
            values['@owner'] = id --Store values in a table for SQL statement
            values['@charge'] = charge.name
            values['@points'] = charge.points
            if string.sub(i, 1, 1) == '4' or string.sub(i, 1, 1) == '5' then
                values['@felony'] = 1
            else
                values['@felony'] = 0
            end

            values['@date'] = date.day .. '/' .. date.month .. '/' .. date.year

            for count = 1, v, 1 do
                MySQL.Async.execute('INSERT INTO criminal_records (owner, charge, points, felony, date) VALUES(@owner, @charge, @points, @felony, @date)', values, function()end)
            end
        end
    end

end)

RegisterServerEvent('yp_cad:addWarrant')
AddEventHandler('yp_cad:addWarrant', function(data)
    local date = os.date('*t')
    local values = {}
    values ['@type'] = data.type
    values['@target'] = data.target
    values['@officer'] = data.officer
    values['@badgenum'] = data.badge
    values['@charges'] = data.charges
    values['@lastloc'] = data.location 
    values['@description'] = data.description
    values['@approval'] = 'PENDING'
    values['@date'] = date.month .. '/' .. date.day .. '/' .. date.year
    MySQL.Async.execute('INSERT INTO warrants (type, target, officer, badgenum, charges, lastloc, approvedby, description, date) VALUES(@type, @target, @officer, @badgenum, @charges, @lastloc, @approval, @description, @date)', values,function(r)end)
end)

RegisterServerEvent('yp_cad:fetchWarrants')
AddEventHandler('yp_cad:fetchWarrants', function(param)
    local paramSpace
    local nameOne
    local nameTwo

    if param then
        paramSpace = string.find(param, ' ')
        nameOne = param
        if paramSpace then --If they put two names in
            nameOne = string.sub(param, 1, paramSpace-1)
            nameTwo = string.sub(param, paramSpace+1)
        end
    end

    local src = source
    MySQL.Async.fetchAll('SELECT * FROM warrants', {}, function(results)
        if param then
            local newResults = {}
            for i, v in ipairs(results) do
                --Get info about current name from Database
                local targetSpace = string.find(v.target, ' ')
                local targetFirst = string.sub(v.target, 1, targetSpace-1)
                local targetTwo = string.sub(v.target, targetSpace+1)

                if paramSpace then --If there was more than one name input
                    if calcDistance(nameOne, targetFirst)/#nameOne <= 0.2 and calcDistance(nameTwo, targetTwo)/#nameTwo <= 0.2 then --If first and last name are close enough
                        table.insert(newResults, v) --Add this warrant
                    end
                elseif calcDistance(nameOne, targetFirst)/#nameOne <= 0.2 or calcDistance(nameOne, targetTwo)/#nameOne <= 0.2 then --If the name entered was close to the first or last name
                    table.insert(newResults, v) --Add this warrant
                end
                
            end
            TriggerClientEvent('yp_cad:getWarrants', src, newResults)
        else
            TriggerClientEvent('yp_cad:getWarrants', src, results)
        end
    end)
end)

RegisterServerEvent('yp_cad:updateWarrantStatus')
AddEventHandler('yp_cad:updateWarrantStatus', function(type, id)
    if type == 'approve' then
        local xPlayer = ESX.GetPlayerFromId(source).getIdentifier()
        MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @id', {['@id'] = xPlayer}, function(results)
            local name = results[1].firstname .. ' ' .. results[1].lastname
            MySQL.Async.execute('UPDATE warrants SET approvedby = @name WHERE id = @id', {['@name'] = name, ['@id'] = id}, function(r)end)
        end)
    else
        MySQL.Async.execute('UPDATE warrants SET approvedby = @name WHERE id = @id', {['@name'] = 'DENIED', ['@id'] = id}, function(r)end)
    end
end)

RegisterServerEvent('yp_cad:closeWarrant')
AddEventHandler('yp_cad:closeWarrant', function(id)
    print(id)
    MySQL.Async.execute('DELETE FROM warrants WHERE id = @id', {['@id'] = id}, function(r)end)
end)

--Dev stuff only below this point

RegisterCommand('getlaw', function(source, args)
    MySQL.Async.fetchAll('SELECT * FROM lawbook', {}, 
    function(results)
        lawbook = results
        --[[for i, v in ipairs(results) do
            lawbook[v.code] = v
        end]]--
    end)
end)

RegisterCommand('convert', function(source, args)
    MySQL.Async.fetchAll('SELECT * FROM user_crimes', {}, function(results)
        for i, v in ipairs(results) do
            local record = json.decode(v.record)
            for index, value in pairs(record) do
                if value > 0 then
                    values = {}
                    values['@owner'] = v.identifier
                    values['@charge'] = lawbook[index].name
                    values['@points'] = lawbook[index].points
                    if string.sub(index, 1, 1) == '4' or string.sub(index, 1, 1) == '5' then
                        values['@felony'] = 1
                    else
                        values['@felony'] = 0
                    end

                    local date = os.date('*t')
                    values['@date'] = date.day .. '/' .. date.month .. '/' .. date.year
                    MySQL.Async.execute('INSERT INTO criminal_records (owner, charge, points, felony, date) VALUES(@owner, @charge, @points, @felony, @date)', values, function()end)
                end
            end
        end
    end)
end)