--ESX Init
ESX = nil

local JobAccess = {'police', 'fib', 'ems'}
local UIEnabled = false
local radio = 11.11

function enableUI(enable)
	UIEnabled = enable
	SetNuiFocus(enable, enable)
	SendNUIMessage({
		type = 'ui',
		enable = enable,
		channel = radio
	})
end

RegisterNetEvent('yp_radio:openRadio')
AddEventHandler('yp_radio:openRadio', function()
	enableUI(true)
end)

RegisterNUICallback('exit', function(data, cb)
	enableUI(false)
	cb('ok')
end)

RegisterNUICallback('swapChannel', function(data, cb)
	local channel = tonumber(data.channel)
	radio = channel
	TriggerServerEvent('yp_base:getPlayerJob', 'yp_radio:joinRadio')
	cb('ok')
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('yp_radio:joinRadio')
AddEventHandler('yp_radio:joinRadio', function(job)
	if radio <= 10.0 then
		local canConnect = false
		for i, v in ipairs(JobAccess) do
			if job == v then
				canConnect = true
				break
			end
		end
		if not canConnect then 
			exports['mythic_notify']:DoHudText('error', 'This channel is encrypted')
			return
		end
	end

	exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "radio:channel", radio, true)
	exports['tokovoip_script']:addPlayerToRadio(radio)
	exports['mythic_notify']:DoHudText('inform', 'Connected to channel ' .. radio)
end)

RegisterNetEvent('yp_radio:leaveRadio')
AddEventHandler('yp_radio:leaveRadio', function()
	if radio ~= -1 then
		exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "radio:channel", 'nil', true)
		exports['tokovoip_script']:removePlayerFromRadio(radio)
		exports['mythic_notify']:DoHudText('inform', 'Disconnected from radio')
	else
		exports['mythic_notify']:DoHudText('error', 'You are not connected to the radio')
	end
end)

RegisterCommand('radiotest', function(source, args)
  local playerName = GetPlayerName(PlayerId())
  local data = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

  print(tonumber(data))

  if data == "nil" then
    exports['mythic_notify']:DoHudText('inform', 'not on radio')
  else
   exports['mythic_notify']:DoHudText('inform', 'on ' .. tonumber(data) .. '.00 MHz </b>')
 end

end, false)


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while true do

		Citizen.Wait(0)
	end
end)
