--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

local blips = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--Functions
function openLestersShop()
	local elements = LestersItems
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lesters_shop', {
		title = 'Black Market', 
		align = 'bottom-right',
		elements = elements
	},
	function(data, menu)
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lesters_shop_amount', {title = 'Amount'},
			function(data2, menu2)
				local amount = tonumber(data2.value)
				if amount > 0 then
					menu2.close()
					TriggerServerEvent('yp_addons:buyItemBM', data.current.value, amount, data.current.price)
				else
					exports['mythic_notify']:DoHudText('error', 'Amount must be greater than 0')
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
	end,
	function(data, menu)
		menu.close()
	end)
end

--Events
RegisterNetEvent('yp_addons:placeCone')
AddEventHandler('yp_addons:placeCone', function()
	local playerPed = GetPlayerPed(-1)
	local coords = GetEntityCoords(playerPed)
	local forward = GetEntityForwardVector(playerPed)
	local x, y, z = table.unpack(coords + forward * 1.0)

	ESX.Game.SpawnObject('prop_roadcone02a', {x = x, y = y, z = z}, function(obj)
		SetEntityHeading(obj, GetEntityHeading(playerPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end)

RegisterNetEvent('yp_addons:find911Blip')
AddEventHandler('yp_addons:find911Blip', function(args)
	local pos = GetEntityCoords(GetPlayerPed(-1))
	TriggerServerEvent('yp_addons:send911Info', pos, args)
end)

RegisterNetEvent('yp_addons:create911Blip')
AddEventHandler('yp_addons:create911Blip', function(name, pos, args)
	local message = table.concat(args, ' ')
	TriggerEvent('chat:addMessage', {color = {255, 0, 0}, multiline = false, args = {'911 ' .. name, message}})
	local temp = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(temp, 66)
	SetBlipDisplay(temp, 4)
	SetBlipScale(temp, 1.0)
	SetBlipColour(temp, 3)
	SetBlipAsShortRange(temp, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("911 Call")
	EndTextCommandSetBlipName(temp)
	Citizen.CreateThread(function()
		Citizen.Wait(120000)
		RemoveBlip(temp)
	end)
end)

RegisterNetEvent('yp_addons:addAmmo')
AddEventHandler('yp_addons:addAmmo', function(ammoType)
	local ped = GetPlayerPed(-1)
	local hash = nil
	if ammoType == 'pAmmo' then
		hash = GetHashKey('WEAPON_PISTOL')
	elseif ammoType == 'arAmmo' then
		hash = GetHashKey('WEAPON_ASSAULTRIFLE')
	elseif ammoType == 'sgAmmo' then
		hash = GetHashKey('WEAPON_PUMPSHOTGUN')
	elseif ammoType == 'smgAmmo' then
		hash = GetHashKey('WEAPON_SMG')
	end
	AddAmmoToPed(ped, hash, 30)
end)

function moveSeat(seatNum)
	local ped = GetPlayerPed(-1)
	if IsPedInAnyVehicle(ped, false) then
		local vehicle = GetVehiclePedIsIn(ped)
		if GetPedInVehicleSeat(vehicle, seatNum-1) ~= ped then
			if IsVehicleSeatFree(vehicle, seatNum-1) then
				SetPedIntoVehicle(ped, vehicle, seatNum-1)
			else
				exports['mythic_notify']:DoHudText('error', 'Someone is alreay in this seat!')
			end
		else
			exports['mythic_notify']:DoHudText('error', 'You are already in this seat')
		end
	end
end

RegisterCommand("shuff", function(source, args, raw) --change command here
	moveSeat(0)
    TriggerEvent("SeatShuffle")
end, false) --False, allow everyone to run it

RegisterCommand('shuff2', function(source, args)
	moveSeat(1)
end, false)

RegisterCommand('shuff3', function(source, args)
	moveSeat(2)
end, false)

RegisterCommand('shuff4', function(source, args)
	moveSeat(3)
end, false)

Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed))

		--Lesters house lockpicks/brutedrives
		if Vdist(x, y, z, 1275.6920, -1710.6605, 54.7714) < 1.5 then
			exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to buy materials')
			if IsControlJustPressed(0, 51) then
				openLestersShop()
			end
		end
		
		Citizen.Wait(0)
	end
end)