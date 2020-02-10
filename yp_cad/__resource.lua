resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    "client.lua"
}

server_scripts {
    "server.lua",
    "@mysql-async/lib/MySQL.lua"
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/listener.js',
	'html/img/lcso_back.png',
	'html/img/ls_seal.png'
}
