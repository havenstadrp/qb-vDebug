fx_version 'cerulean'

game 'gta5'
description "Vehicle debugger for tune balancing"
version '1.0.0'

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}

shared_scripts {
	'shared/init.lua',
	'shared/config.lua',
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.css',
    'html/*.js',
}

lua54 'yes'