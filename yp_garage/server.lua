--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()
	MySQL.Async.execute("UPDATE owned_vehicles SET state = true WHERE state = false", {}, function() end)
end)


RegisterServerEvent('yp_garage:storeVehicle')
AddEventHandler('yp_garage:storeVehicle', function(plateNum, name, vehData)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local valid = false
	local fetching = true

	Citizen.CreateThread(function()
		MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {['@plate'] = plateNum},
		function(results)
			if results ~= nil and #results > 0 then
				valid = true
				fetching = false		
			end

			if valid then
				if vehData ~= nil then
					MySQL.Async.execute("UPDATE owned_vehicles SET state = true, garage_name = @name, vehicle = @vehicle WHERE plate = @plate", {['@plate'] = plateNum, ['@name'] = name, ['@vehicle'] = json.encode(vehData)},
						function()
							TriggerClientEvent('yp_garage:deleteCar', src)
						end)
				else
					MySQL.Async.execute("UPDATE owned_vehicles SET state = true, garage_name = @name WHERE plate = @plate", {['@plate'] = plateNum, ['@name'] = name},
						function()
							
						end)
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'error', text = 'This vehicle does not have a valid registration.', length = 2500})
			end

		end)
		
	end)
end)

RegisterServerEvent('yp_garage:getVehicles')
AddEventHandler('yp_garage:getVehicles', function(name)
	local xPlayer = ESX.GetPlayerFromId(source)
	local src = source
	local data = {}
	--print(xPlayer.identifier)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier AND garage_name = @name", {['@identifier'] = xPlayer.identifier, ['@name'] = name}, --, state, garage_name, name, plate
		function(results)

			if results ~= nil and #results > 0 then
				for i = 1, #results, 1 do
					local this_data = {}
					local vehName = results[i].name .. ' [' .. results[i].plate .. ']'
					local state = results[i].state

					if state then
						this_data['value'] = results[i].vehicle
					else
						vehName = vehName .. ' (out)'
						this_data['value'] = 'not_stored'
					end
					this_data['label'] = vehName
					this_data['plate'] = results[i].plate
					data[i] = this_data
				end
				TriggerClientEvent('yp_garage:openVehicleMenu', src, data)
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'error', text = 'You do not have any vehicles in this garage', length = 2500})
			end
		end)
end)

RegisterServerEvent('yp_garage:getAllVehicles')
AddEventHandler('yp_garage:getAllVehicles', function(garageName)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local data = {}
	MySQL.Async.fetchAll('SELECT state, garage_name, name, plate FROM owned_vehicles WHERE owner = @identifier', {['@identifier'] = xPlayer.identifier},
		function(results)
			if results ~= nil and #results > 0 then
				for i = 1, #results, 1 do
					local this_data = {}

					--Format garage name
					local garage = results[i].garage_name
					garage = string.sub(garage, 1, string.find(garage, 'garage')-2)
					--[[
					Make garage name look prettier later.
					for v = 1, #garage, 1 do
						if garage[v] == '_' then
							garage[v] = ' '
						end
					end
					]]--

					this_data['label'] = results[i].name .. ' [' .. results[i].plate .. '] '
					if not results[i].state then
						this_data['label'] = this_data['label'] .. '(out)'
						this_data['value'] = 'out'
					else
						this_data['label'] = this_data['label'] .. '(' .. garage .. ')'
						this_data['value'] = results[i].garage_name
					end
					this_data['plate'] = results[i].plate
					data[i] = this_data
				end
				TriggerClientEvent('yp_garage:openInsureMenu', src, data, garageName)
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = 'inform', text = 'You do not own any vehicles.', length = 2500})
			end
		end)
end)

RegisterServerEvent('yp_garage:pullVehicle')
AddEventHandler('yp_garage:pullVehicle', function(plateNum)
	MySQL.Async.execute("UPDATE owned_vehicles SET state = false WHERE plate = @plate", {['@plate'] = plateNum},function() end)
end)

RegisterServerEvent('yp_garage:renameVehicle')
AddEventHandler('yp_garage:renameVehicle', function(plate, name)
	print(plate)
	print(name)
	MySQL.Async.execute('UPDATE owned_vehicles SET name = @name WHERE plate = @plate', {['@name'] = name, ['@plate'] = plate},function() end)
end)
