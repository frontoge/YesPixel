local houses = {}
local blips = {}
local inside = false
local model = nil
local currentHouse = nil
local houseInd
local id = nil

local DEBUG = true
local addingHouse = false --Dev Remove before release
local newHouse = {}


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
    ESX.PlayerData = xPlayer
    TriggerServerEvent('yp_housing:requestHouseData')
end)

if DEBUG then
    RegisterNetEvent('playerSpawned')
    AddEventHandler('playerSpawned', function()
        TriggerServerEvent('yp_housing:requestHouseData')
    end)
end

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
        FreezeEntityPosition(model, true)
        SetEntityCoords(GetPlayerPed(-1), pos.x + houseData[door].xoff, pos.y + houseData[door].yoff, pos.z - houseData.down + 1)
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
                TriggerServerEvent("yp_housing:getHouseInv", houseId)
            end
            menu.close()
        end,
        function(data, menu)
            menu.close()
        end)
end

function setHouseLockCode(houseId)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'house_lock', {title='Keycode for house'},
    function(data, menu)
        local value = tonumber(data.value)
        if value < 0 or value > 9999 then
            exports['mythic_notify']:DoHudText('error', 'This code is invalid, please use number between 0 and 9999')
        else
            TriggerServerEvent('yp_housing:setHouseLockCode', houseId, value)
            menu.close()
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function addBlip(houseId)
    local house = houses[houseId]
    blips[houseId] = AddBlipForCoord(house.front.x, house.front.y, house.front.z)
	SetBlipSprite(blips[houseId], 492)
	SetBlipScale(blips[houseId], 1.0)
	SetBlipColour(blips[houseId], 69)
	SetBlipAsShortRange(blips[houseId], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("House")
	EndTextCommandSetBlipName(blips[houseId])
end

function addVacantBlip(houseId)
    local house = houses[houseId]
    blips[houseId] = AddBlipForCoord(house.front.x, house.front.y, house.front.z)
	SetBlipSprite(blips[houseId], 374)
	SetBlipScale(blips[houseId], 1.0)
	SetBlipColour(blips[houseId], 0)
	SetBlipAsShortRange(blips[houseId], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("House Sale")
	EndTextCommandSetBlipName(blips[houseId])
end

function addSoldBlip(houseId)
    local house = houses[houseId]
    blips[houseId] = AddBlipForCoord(house.front.x, house.front.y, house.front.z)
	SetBlipSprite(blips[houseId], 374)
	SetBlipScale(blips[houseId], 1.0)
	SetBlipColour(blips[houseId], 69)
	SetBlipAsShortRange(blips[houseId], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Sold House")
	EndTextCommandSetBlipName(blips[houseId])
end

function removeBlip(houseId)
    RemoveBlip(blips[houseId])
    blips[houseId] = nil
end

--Enter the code to get into the house
function tryCode(id, houseData, position)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'enter_keycode', {title="Enter keycode"},
    function(data, menu)
        local value = tonumber(data.value)
        if value < 0 or value > 9999 then
            exports['mythic_notify']:DoHudText('error', 'This code is invalid, please use number between 0 and 9999')
        elseif value == houseData.code then
            print('correct code')
            houseData.locked = 0
            attemptToEnter(id, houseData, position)
            houseData.locked = 1
            menu.close()
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function attemptToEnter(id, houseData, position)
    if houseData.locked == 0 then--If the house is not locked 
        currentHouse = houseData
        houseId = id
        if position == 'front'  then
            TriggerServerEvent('yp_housing:requestInterior', id, houseData.front, 'front')
        else
            TriggerServerEvent('yp_housing:requestInterior', id, houseData.back, 'back')
        end
    else
        exports['mythic_notify']:DoHudText('inform', 'This house is locked.')
        tryCode(id, houseData, position)
    end
end

--Commands
RegisterCommand('enter', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    if inside then return end
    for i, v in ipairs(houses) do
        if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then
            attemptToEnter(i, v, 'front')
        elseif v.back and Vdist(pos.x, pos.y, pos.z, v.back.x, v.back.y, v.back.z) < 1 then
            attemptToEnter(i, v, 'back')
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
                TriggerServerEvent('yp_housing:leaveHouse', houseId)--Unload model if you are the last one out
                --Update vars/resync with outside time
                inside = false
                TriggerEvent('vSync:resync')
                currentHouse = nil
                houseId = nil
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
                    TriggerServerEvent('yp_housing:leaveHouse', houseId)
                    inside = false
                    TriggerEvent('vSync:resync')
                    currentHouse = nil
                    houseId = nil
                end
            end
        end
    end)
end)

RegisterCommand('houseInfo', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    for i, v in pairs(houses) do
        if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then
            TriggerEvent("chat:addMessage", {color = {100, 200, 0}, multiline = false, args = {"House Info", "This house costs $" .. v.price}})
            if v.owner then
                TriggerEvent("chat:addMessage", {color = {100, 200, 0}, multiline = false, args = {"House Info", "This house is owned"}})
            else
                TriggerEvent("chat:addMessage", {color = {100, 200, 0}, multiline = false, args = {"House Info", "This house is not owned"}})
            end
            if DEBUG then
                TriggerEvent("chat:addMessage", {color = {100, 200, 0}, multiline = false, args = {"House Info", "ID:" .. v.id}})
            end
            return
        end
    end
end)

RegisterCommand('sellHouse', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    for i, v in pairs(houses) do
        if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then
            TriggerServerEvent('yp_housing:sellHouse', tonumber(args[1]), i)
            return
        end
    end
end)

RegisterCommand('lock', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    for i, v in pairs(houses) do
        if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then
            if v.owner == id then
                if v.locked == 0 then
                    exports['mythic_notify']:DoHudText('inform', 'House locked')
                else
                    exports['mythic_notify']:DoHudText('inform', 'House unlocked')
                end
                TriggerServerEvent('yp_housing:toggleLock', i)
            else
                exports['mythic_notify']:DoHudText('error', 'You do not own this house')
            end
            return
       end
    end
end)

RegisterCommand('setlock', function(source, args)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    for i, v in pairs(houses) do
        if Vdist(pos.x, pos.y, pos.z, v.front.x, v.front.y, v.front.z) < 1 then
            if v.owner == id then
                setHouseLockCode(i)
                return
            end
        end
    end
end)

--Events
RegisterNetEvent('yp_housing:receiveHouseData')
AddEventHandler('yp_housing:receiveHouseData', function(data, steam)
    houses = data
    id = steam
    for i, v in ipairs(houses) do
        if v.owner == id then --If this house is owned by the user add a blip
            addBlip(i)
        end
    end
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
                TriggerServerEvent('yp_housing:removeItemFromHouse', houseId, {name = data.current.name, value = numVal})
                TriggerServerEvent('yp_housing:getHouseInv', houseId)
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

RegisterNetEvent('yp_housing:getHouse')
AddEventHandler('yp_housing:getHouse', function(houseNum)
    TriggerEvent("chat:addMessage", {color = {100, 200, 0}, multiline = false, args = {"House Info", "You now own a house!"}})
    addBlip(houseNum)
    setHouseLockCode(houseNum)
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
                TriggerServerEvent('yp_housing:addItemToHouse', houseId, {name = data.current.name, value = numVal})
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

RegisterNetEvent('yp_housing:updateHouse')
AddEventHandler('yp_housing:updateHouse', function(houseId, houseData)
    houses[houseId] = houseData
end)

RegisterNetEvent('yp_housing:sendHouseBill')
AddEventHandler('yp_housing:sendHouseBill', function(target, amount)
    TriggerServerEvent('esx_billing:sendBill', target, 'society_realty', 'House', amount)
end)

RegisterNetEvent('yp_housing:showVacantHouses')
AddEventHandler('yp_housing:showVacantHouses', function()
    TriggerEvent('yp_housing:hideVacantHouses')
    for i, v in pairs(houses) do
        if not v.owner then
            addVacantBlip(i)
        elseif v.owner ~= id then
            addSoldBlip(i)
        else
            addBlip(i)
        end
    end
end)

RegisterNetEvent('yp_housing:hideVacantHouses')
AddEventHandler('yp_housing:hideVacantHouses', function()
    for i, v in pairs(houses) do
        if v.owner ~= id then
            removeBlip(i)
        end
    end
end)

--Thread
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

--Dev Remove before release
if DEBUG then
    RegisterCommand('addhouse', function(source, args)
        if not args[1] or not args[2] then print('invalid command') return end
        addingHouse = true
        newHouse['@model'] = tonumber(args[1])
        newHouse['@price'] = tonumber(args[2])
        newHouse['@locked'] = true
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
end