resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    "client/client.lua",
    "config.lua"
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
    "server/server.lua",
    "config.lua"
}