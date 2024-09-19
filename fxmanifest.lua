fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'sobing'
description 'vehicleshop qbcore like nopixel 4.0'

ui_page 'html/index.html'

shared_scripts {
	'shared/cores.lua',
    'shared/fuels.lua',
    'shared/keys.lua',
	'shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'shared/config.lua',
    'shared/vehicles.lua',
}

client_scripts {
	'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
	'html/index.html',
	'html/style.css',
	'html/index.js',
    'html/files/*.png',
    'html/files/*.webp',
    'html/files/*.jpg',
	'html/fonts/*.ttf',
    'html/customcars/*.png',
}