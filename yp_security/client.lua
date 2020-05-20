
Citizen.CreateThread(function()
    while true do
        local currentTime = GetClockHours()
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        
        if currentTime >= LockTimes.start or currentTime < LockTimes.finish then
            for i, v in ipairs(DoorModels) do
                local closest = GetClosestObjectOfType(x, y, z, 20.0, v)
                if closest then
                    print(closest)
                    FreezeEntityPosition(closest, true)
                end
            end
        end

        Citizen.Wait(0)
    end
end)