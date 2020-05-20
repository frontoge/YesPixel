local houses = {}
local inside = false
local model = nil
local currentHouse = nil
local PlayerData = nil

local addingHouse = false --Dev Remove before release
local newHouse = {}
local DEBUG = true

---FRAMEWORK (To be replaced with YP before framework release)---
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)
---END FRAMEWORK---

--Init
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('yp_housing:requestHouseData')
end)

function goInside(pos, door, load)
    Citizen.CreateThread(function()
        RequestAnimDict('mp_common')
        while not HasAnimDictLoaded('mp_common') do Citizen.Wait(0) end
        TaskPlayAnim(GetPlayerPed(-1), 'mp_common', 'givetake1_a', 1.0, -1.0, 1500, 49, 1, false, false, false)
        Citizen.Wait(1500)
        RemoveAnimDict('mp_common')
        TriggerEvent('vSync:unsync')
        local houseData = houseInteriors[currentHouse.model]
        if load then
            model = CreateObject(GetHashKey(houseData.name), pos.x, pos.y, pos.z - houseData.down, 1, 1, 0)
        else
            model = GetClosestObjectOfType(pos.x, pos.y, pos.z - houseData.down, 10.0, GetHashKey(houseData.name))
        end
        print("model:" .. model)
        FreezeEntityPosition(model, true)
        SetEntityCoords(GetPlayerPed(-1), pos.x + houseData[door].xoff, pos.y + houseData[door].yoff, pos.z - houseData.down + 1)
        --SetEntityCoords(GetPlayerPed(-1), pos.x , pos.y , pos.z - 29)
        SetEntityHeading(model, 100.0)
        SetEntityHeading(GetPlayerPed(-1), 100.0)
        inside = true
    end)
end

function openHouseInvMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'interaction_choice', {
        title = 'House Inventory',
        align = 'bottom-right',
        elements = {
            {label = 'Deposit', value = 'deposit'},
            {label = 'Withdraw', value = 'remove'}
        }},
        function(data, menu)
            if (data.current.value == 'deposit') then
                TriggerServerEvent('yp_housing:getPlayerInv')
            elseif data.current.value == 'remove' then
                TriggerServerEvent("yp_housing:getHouseInv", currentHouse.id)
            end
            menu.close()
        end,
        function(data, menu)
            menu.close()
        end)
end

RegisterCommand('enter', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    print(#houses)
    for i, v in pairs(houses) do
        --print("Owner: " .. v.owner)
        if DEBUG or (not inside and (v.owner == PlayerData.identifier or v.locked == 0)) then --If the player is not inside and they are the owner or the door is unlocked
            if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then 
                currentHouse = v
                TriggerServerEvent('yp_housing:requestInterior', currentHouse.id, v.front, 'front')
            elseif v.back then
                if Vdist(pos.x, pos.y, pos.z, v.back.x, v.back.y, v.back.z) < 1 then
                    currentHouse = v
                    TriggerServerEvent('yp_housing:requestInterior', currentHouse.id, v.front, 'back')
                end
            end
        end
    end
end)

RegisterCommand('exit', function(source, args)
    Citizen.CreateThread(function()
        if inside then
            local houseData = houseInteriors[currentHouse.model] --Model names and exit offsets
            local front = {}
            front.x, front.y, front.z = table.unpack(GetEntityCoords(model)) --Get the current coordinates of the model
            local pos = GetEntityCoords(GetPlayerPed(-1)) --Get Players position
            front.x = front.x + houseData.front.xoff --Add the offsets for the exit
            front.y = front.y + houseData.front.yoff
            front.z = front.z + houseData.front.zoff

            if Vdist(pos.x, pos.y, pos.z, front.x, front.y, front.z) < 2 then
                --Play Animation
                RequestAnimDict('mp_common')
                while not HasAnimDictLoaded('mp_common') do Citizen.Wait(0) end
                TaskPlayAnim(GetPlayerPed(-1), 'mp_common', 'givetake1_a', 1.0, -1.0, 1500, 49, 1, false, false, false)
                Citizen.Wait(1500)
                RemoveAnimDict('mp_common')

                SetEntityCoords(GetPlayerPed(-1), currentHouse.front.x, currentHouse.front.y, currentHouse.front.z)--Remove player from house
                TriggerServerEvent('yp_housing:leaveHouse', currentHouse.id)--Unload model if you are the last one out
                --Update vars/resync with outside time
                inside = false
                TriggerEvent('vSync:resync')
                currentHouse = nil
            elseif houseData.back then--Same thing for back door
                local back = {}
                back.x, back.y, back.z = table.unpack(GetEntityCoords(model))
                back.x = back.x + houseData.back.xoff --Add the offsets for the exit
                back.y = back.y + houseData.back.yoff
                back.z = back.z + houseData.back.zoff
                if Vdist(pos.x, pos.y, pos.z, back.x, back.y, back.z) < 2 then
                    RequestAnimDict('mp_common')
                    while not HasAnimDictLoaded('mp_common') do Citizen.Wait(0) end
                    TaskPlayAnim(GetPlayerPed(-1), 'mp_common', 'givetake1_a', 1.0, -1.0, 1500, 49, 1, false, false, false)
                    Citizen.Wait(1500)
                    RemoveAnimDict('mp_common')
                    SetEntityCoords(GetPlayerPed(-1), currentHouse.back.x, currentHouse.back.y, currentHouse.back.z)
                    TriggerServerEvent('yp_housing:leaveHouse', currentHouse.id)
                    inside = false
                    TriggerEvent('vSync:resync')
                    currentHouse = nil
                end
            end
        end
    end)
end)

--Events
RegisterNetEvent('yp_housing:recieveHouseData')
AddEventHandler('yp_housing:recieveHouseData', function(data)
    houses = data
end)

RegisterNetEvent('yp_housing:enterHouse')
AddEventHandler('yp_housing:enterHouse', function(pos, door, load)
    goInside(pos, door, load)
end)

RegisterNetEvent('yp_housing:exitHouse')
AddEventHandler('yp_housing:exitHouse', function(unload)
    if unload then
        Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(model))
    end
    model = nil
end)

Citizen.CreateThread(function(source, args)
    while true do
        if inside then
            local houseData = houseInteriors[currentHouse.model]
            local pos = GetEntityCoords(GetPlayerPed(-1))
            local inv = {}
            inv.x, inv.y, inv.z = table.unpack(GetEntityCoords(model))
            if Vdist(pos.x, pos.y, pos.z, inv.x + houseData.inv.xoff, inv.y + houseData.inv.yoff, inv.z + houseData.inv.zoff) < 1 then
                exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to Open Storage')
                if IsControlJustPressed(0, 51) then
                    openHouseInvMenu()
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('yp_housing:depositItem')
AddEventHandler('yp_housing:depositItem', function(inv)
    local elements = inv
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'deposit_menu', {
        title = 'Deposit Items',
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_amount', {title = 'How many'},
        function(data2, menu2)
            local numVal = tonumber(data2.value)
            if (numVal <= data.current.value and numVal > 0) then
                TriggerServerEvent('yp_housing:addItemToHouse', currentHouse.id, {name = data.current.name, value = numVal})
                TriggerServerEvent('yp_housing:getPlayerInv')
                menu.close()
                menu2.close()
            else
                exports['mythic_notify']:DoHudText('error', 'Invalid amount', 3000)
            end
        end,
        function(data2, menu2)
            menu2.close()
        end)
    end,
    function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent('yp_housing:pullItem')
AddEventHandler('yp_housing:pullItem', function(houseInv)
    local elements = houseInv
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'withdraw_menu', {
        title = 'Withdraw Item',
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_amount', {title = 'How many'},
        function(data2, menu2)
            local numVal = tonumber(data2.value)
            if (numVal <= data.current.value and numVal > 0) then
                TriggerServerEvent('yp_housing:removeItemFromHouse', currentHouse.id, {name = data.current.name, value = numVal})
                TriggerServerEvent('yp_housing:getHouseInv', currentHouse.id)
                menu.close()
                menu2.close()
            else
                exports['mythic_notify']:DoHudText('error', 'Invalid amount', 3000)
            end
        end,
        function(data2, menu2)
            menu2.close()
        end)
    end,
    function(data, menu)
        menu.close()
    end)
end)

--Dev Remove before release
RegisterCommand('addhouse', function(source, args)
    addingHouse = true
    newHouse['@model'] = tonumber(args[1])
    newHouse['@locked'] = false
    newHouse['@inv'] = json.encode({})
end)

RegisterCommand('frontDoor', function(source, args)
    if addingHouse then
        --Add front door location
        local pos = {}
        pos.x, pos.y, pos.z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        newHouse['@front'] = json.encode(pos)
        --Add Heading
        newHouse['@heading'] = GetEntityHeading(GetPlayerPed(-1))
    end
end)

RegisterCommand('backDoor', function(source, args)
    if addingHouse then
        local pos = {}
        pos.x, pos.y, pos.z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        newHouse['@back'] = json.encode(pos)
    end
end)

RegisterCommand('garage', function(source, args)
    if addingHouse then
        local pos = {}
        pos.x, pos.y, pos.z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        pos.heading = GetEntityHeading(GetPlayerPed(-1))
        newHouse['@garage'] = json.encode(pos)
    end
end)

RegisterCommand('finish', function(source, args)
    if newHouse['@front'] then
        addingHouse = false
        TriggerServerEvent('finishHouse', newHouse)
    end
end)

RegisterNetEvent('addPlayer')
AddEventHandler('addPlayer', function(player)
    PlayerData = player
end)