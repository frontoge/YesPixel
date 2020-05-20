--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX init
ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

--Script Locals
local cart = {}
local totalCost = 0
local storeBlips = {}

--Functions
function addToCart(name, cost, amount)
	local inCart = false
	local index = -1
	for i, v in ipairs(cart) do
		if v.item == name then
			inCart = true
			index = i
			break
		end
	end

	if not inCart then
		table.insert(cart, {item = name, count = amount})
	else
		cart[index].count = cart[index].count + amount
	end

	totalCost = totalCost + (cost * amount)
end

function resetCart()
	cart = {}
	totalCost = 0
end

function openCartMenu(store)
	local elements = Menus[store.type]

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cart_menu', {title = 'Store Items', align = 'bottom-right', elements = elements},
		function(data, menu)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'item_count', {title = 'Enter the amount'},
				function(data2, menu2)
					menu2.close()
					local count = data2.value
					addToCart(data.current.value, data.current.cost, count)
				end,
				function(data2, menu2)
					menu2.close()
					if store.type == 'burgershot' then
						openCheckoutMenu()
					end
				end)

		end,
		function(data, menu)
			menu.close()
			exports['mythic_notify']:DoHudText('inform', 'You have $' .. totalCost .. ' of items to your cart')
		end)
end

function openCheckoutMenu()
	if #cart > 0 then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'checkout_menu', {
			title = 'Checkout ($' .. totalCost .. ')',
			align = 'bottom-right',
			elements =
			{
				{label = 'Pay with cash', value = 'cash'},
				{label = 'Pay with card', value = 'card'}
			}},
			function(data, menu)
				menu.close()
				TriggerServerEvent('yp_stores:checkout', data.current.value, cart, totalCost)
				resetCart()
			end,
			function(data, menu)
				menu.close()
				exports['mythic_notify']:DoHudText('inform', 'Checkout cancelled')
			end)
	else
		exports['mythic_notify']:DoHudText('error', 'There is nothing in your cart')
	end
end

--Create Blips 
Citizen.CreateThread(function()
	for i, v in ipairs(Stores) do
		storeBlips[i] = AddBlipForCoord(v.cart.x, v.cart.y, v.cart.z)
		SetBlipSprite(storeBlips[i], 59)
		SetBlipDisplay(storeBlips[i], 4)
		SetBlipScale(storeBlips[i], 1.0)
		SetBlipColour(storeBlips[i], 2)
		SetBlipAsShortRange(storeBlips[i], true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Store")
		EndTextCommandSetBlipName(storeBlips[i])
	end
end)

--Main Thread
Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed)

		for i, v in ipairs(Stores) do
			if Vdist(pos.x, pos.y, pos.z, v.cart.x, v.cart.y, v.cart.z) < 30 then
				DrawMarker(1, v.cart.x, v.cart.y, v.cart.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.75, 2.75, 1.0, 0, 0, 255, 255, false, false, 2, false, nil, nil, false)
				if Vdist(pos.x, pos.y, pos.z, v.cart.x, v.cart.y, v.cart.z) < 2 then -- Add items to cart
					exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to browse items')
					if IsControlJustPressed(0,51) then
						openCartMenu(v)
					end
				end

				for i2, v2 in ipairs(v.registers) do
					if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 1 then
						exports['yp_base']:DisplayHelpText('Press ~INPUT_CONTEXT~ to checkout')
						if IsControlJustPressed(0,51) then
							openCheckoutMenu()
						end
					end
				end

				for i2, v2 in ipairs(v.exits) do
					if Vdist(pos.x, pos.y, pos.z, v2.x, v2.y, v2.z) < 1 then
						if #cart > 0 then
							exports['mythic_notify']:DoHudText('inform', 'The items in your cart have been returned')
							resetCart()
						end
					end
				end

			end
		end

		Citizen.Wait(0)
	end
end)