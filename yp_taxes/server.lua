--[[ Copyright (C) Matthew Widenhouse - All Rights Reserved
 * Unauthorized copying of this file, without written consent from the owner, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Matthew Widenhouse <widenhousematthew@gmail.com>, September 2019
]]--

--ESX Init
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function applyTax(src, type, amount)
	local xPlayer = ESX.GetPlayerFromId(src)
	local tax = 0
	if type == 'sales' then
		tax = amount * (salesRate / 100.0)
	elseif type == 'income' then
		tax = amount * (incomeRate / 100.0)
	elseif type == 'corporate' then
		tax = amount * (corporateRate / 100.0)
	elseif type == 'property' then
		tax = amount * (propertyRate / 100.0)
	end

	xPlayer.removeAccountMoney('bank', tax)
	TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = tax .. ' was charged for taxes.' , length = 2500})
	
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_city', function(account)
		account.addMoney(tax)
	end)
end


RegisterCommand('taxrate', function(source, args)
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The Sales Tax rate is: ' .. salesRate .. '%', length = 4000})
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The Income Tax rate is: ' .. incomeRate .. '%' , length = 4000})
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The Corporate Tax rate is: ' .. corporateRate .. '%' , length = 4000})
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The Property Tax Rate is: ' .. propertyRate .. '%' , length = 4000})
end, false)