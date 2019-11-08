--ESX Init
ESX = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local radio = -1

RegisterNetEvent('yp_radio:joinRadio')
AddEventHandler('yp_radio:joinRadio', function(channel)
	radio = channel
	exports['tokovoip_script']:setPlayerData(GetPlayerName(PlayerId()), "radio:channel", channel, true)
	exports['tokovoip_script']:addPlayerToRadio(channel)
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
