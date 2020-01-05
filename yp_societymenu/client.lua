local uiEnabled = false
local societyBalance = nil
local society = nil

SetNuiFocus(false, false)

--UI Functions
function enableUI(enable)
	SetNuiFocus(enable, enable)
	uiEnabled = enable
	SendNUIMessage({
		type = 'ui',
		enable = enable,
		societyBalance = societyBalance,
		society = society
	})
end

RegisterCommand('exitui', function()
	SetNuiFocus(false, false)
end)

RegisterNUICallback('exit', function(data, cb)
	enableUI(false)
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	print(data.value)
	TriggerServerEvent('yp_societymenu:withdrawSociety', data.value, data.society)
	enableUI(false)
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('yp_societymenu:depositSociety', data.value, data.society)
	enableUI(false)
	cb('ok')
end)

RegisterNetEvent('yp_societymenu:openMenu')
AddEventHandler('yp_societymenu:openMenu', function(societyName)
	TriggerServerEvent('yp_societymenu:getSocietyMoney', societyName)
end)

RegisterNetEvent('yp_societymenu:updateSocietyBalance')
AddEventHandler('yp_societymenu:updateSocietyBalance', function(amount, societyName)
	societyBalance = amount
	society = societyName
	enableUI(true)
end)