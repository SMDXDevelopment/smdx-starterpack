fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'

author 'SkapMicke - SMDX Development'
description 'Starterpack'

shared_scripts {
	'config.lua'
}

   server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'  
}

client_scripts {
    'client/main.lua'
}