
Citizen.CreateThread(function()
    local date = os.date("*t") --Get the current date as a table
    local playerCount = 0
    local newDate
    local fileName = 'logs/log' .. date.day .. '_' .. date.month .. '_' .. date.year .. '(' .. math.floor(date.hour / 8) .. ').log'
    while (true) do
        newDate = os.date('*t')
        playerCount = GetNumPlayerIndices()
        print(newDate.hour .. ':' .. math.floor(newDate.min / 10) .. newDate.min % 10 .. ' GMT, Player Count = ' .. playerCount)
        local log = LoadResourceFile(GetCurrentResourceName(), fileName) 
        if log then
            log = log .. newDate.hour .. ':' .. math.floor(newDate.min / 10) .. newDate.min % 10 .. ' GMT, Player Count = ' .. playerCount .. "\n"
        else
            log = newDate.hour .. ':' .. math.floor(newDate.min / 10) .. newDate.min % 10 .. ' GMT, Player Count = ' .. playerCount .. "\n"
        end
        SaveResourceFile(GetCurrentResourceName(), fileName, log, -1) --Write the data
        Citizen.Wait(600000) --Every 10 Minutes
    end
end)
