fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'thom_politigarage'
description 'Avanceret Politigarage til ESX'

shared_script 'config.lua'

client_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/images/*.png',
    'nui/images/*.jpg',
    'nui/images/*.webp'
}

dependencies {
    'es_extended',
    'ox_lib'
}
