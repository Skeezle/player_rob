fx_version 'cerulean'
game 'gta5'

name 'skeezle_rob'
author 'skeezle'
description 'Rob players via ox_target when hands up or downed (QBX + wasabi_ambulance friendly)'
version '1.2.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
}
