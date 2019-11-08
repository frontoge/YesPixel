resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    "client.lua",
    "config.lua"
}

server_scripts {
    "server.lua",
    "@mysql-async/lib/MySQL.lua",
    "config.lua"
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/listener.js',
	'html/style.css',
	'html/img/flecca.png'
}