--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegsterNetEvent('yp_drugs:actions:useCocaine')
AddEventHandler('yp_drugs:actions:useCocaine', function()
	--[[Cocaine Effects
	Run Faster
	Damage Resistance
	Give Lots of stress
	]]
end)

RegsterNetEvent('yp_drugs:actions:useMeth')
AddEventHandler('yp_drugs:actions:useMeth', function()
	--[[Meth Effects

	]]
end)

RegsterNetEvent('yp_drugs:actions:useHeroin')
AddEventHandler('yp_drugs:actions:useHeroin', function()
	--[[Heroin Effects

	]]
end)

RegsterNetEvent('yp_drugs:actions:useJoint')
AddEventHandler('yp_drugs:actions:useJoint', function()
	--[[Weed Effects
	Lower Stress
	Light Damage Resistance
	]]
end)

RegsterNetEvent('yp_drugs:actions:useVicodin')
AddEventHandler('yp_drugs:actions:useVicodin', function()
	--[[Vicodin Effects
	
	]]
end)

RegsterNetEvent('yp_drugs:actions:useLSD')
AddEventHandler('yp_drugs:actions:useLSD', function()
	--[[LSD Effects
	
	]]
end)

RegsterNetEvent('yp_drugs:actions:useXanax')
AddEventHandler('yp_drugs:actions:useXanax', function()
	--[[Xanax Effects
	
	]]
end)