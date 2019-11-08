RegisterCommand('rate', function(source, args)
	local newAmount = tonumber(args[1])
	TriggerClientEvent('yp_taxi:updateRate', source, newAmount)
end)
