fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'rsg-cold'
author 'Zepherlah & Doku'
version '1.0.0'

server_scripts {
    'config.lua',
    'server/*.lua'
}

client_scripts {
    'config.lua',
    'client/*.lua'
}

dependencies {
    'rsg-core'
}