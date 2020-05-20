ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('yp_extraitems:useItem')
AddEventHandler('yp_extraitems:useItem', function(item)
	Items[item]()
end)