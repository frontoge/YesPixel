resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_scripts {
    "server/server.lua",
    "@mysql-async/lib/MySQL.lua"
}

client_scripts {
	"client/client.lua"
}
exports { 
	"DisplayHelpText",
	"FreezePlayer",
	"UnFreezePlayer",
	"addStress",
	"removeStress",
	"deleteVehicle"
}