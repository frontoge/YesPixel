AddEventHandler('chatMessage', function(source, color, message)
	for i, v in ipairs(Config.BlackChat) do

		if string.find(string.lower(message), v) then
			TriggerEvent('Anticheat:AutoBan', source, {period = -1, reason = 'hax or racism'})
		end 
	end
end)