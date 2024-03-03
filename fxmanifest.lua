fx_version 'bodacious'
lua54 'yes' 
game 'gta5' 

author 'R1CKY®#2220'
description 'Report V2 From Tech Development'
version '1.0'


client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/callback.lua'
}

shared_scripts {
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/configServer.lua',
    'server/functions.lua',
    'server/main.lua'
}

ui_page 'web/index.html'

files {
    'web/*.html',
    'web/css/*.css',
    'web/js/*.js',
    'web/sound/*.mp3',
    'web/fonts/*.ttf',
    'web/img/*.png',
    'web/img/icon/*.png',
}
