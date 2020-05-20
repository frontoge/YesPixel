local racing = false
local finish = {}
local laps = 0
local maxLaps = 1
local timer = 0.0
local lapTime = 0.0
local fastest = nil


function startRace()
    racing = true

    Citizen.CreateThread(function()
        local x, y, z
        local incircle = true
        while racing do
            --GetPlayer Position and check for lap
            x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
            local dist = Vdist(x, y, z, finish.x, finish.y, finish.z)
            if dist < 200 then
                DrawMarker(1, finish.x, finish.y, finish.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 10.0, 255, 255, 0, 180, 0, 0, 0, 0)
                if dist < 10 and not incircle then
                    --If a lap is completed
                    laps = laps + 1
                    --exports['mythic_notify']:DoHudText('inform', 'Lap ' .. laps .. ': ' .. lapTime .. ' ; Total: ' .. timer, 30000)
                    exports['yp_notify']:sendNotif({text = 'Lap ' .. laps .. ': ' .. math.floor(lapTime * 100) / 100 .. ' ; Total: ' .. math.floor(timer * 100) / 100, color = {r = 255, g = 10, b = 10}, duration = 30000})
                    if laps == maxLaps then
                        racing = false
                    end

                    --Update fastest lap
                    if fastest then
                        if lapTime < fastest[2] then
                            fastest = {laps, math.floor(lapTime * 100) / 100}
                        end
                    else
                        fastest = {laps, math.floor(lapTime * 100) / 100}
                    end
                    exports['yp_notify']:sendNotif({text = 'Fastest Lap was: Lap ' .. fastest[1] .. ' @ ' .. fastest[2], color = {r = 255, g = 10, b = 10}, duration = 30000})
                    lapTime = 0.0
                    incircle = true
                elseif incircle and dist >= 10 then
                    incircle = false
                end
            end
            timer = timer + 0.01
            lapTime = lapTime + 0.01
            Citizen.Wait(10)
        end
        finish = {}
        laps = 0
        maxLaps = 1
        timer = 0.0
        lapTime = 0.0
        fastest = nil
    end)
end

RegisterCommand('startRace', function(source, args)
    if racing then return end
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
    finish.x = x
    finish.y = y 
    finish.z = z
    laps = 0
    maxLaps = tonumber(args[1])
    startRace()
end)