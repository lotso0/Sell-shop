-----------------For support, scripts, and more----------------
--------------- https://discord.gg/darksiderp  -------------
---------------------------------------------------------------

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Lotso'
description 'Lotso Sell Shop'
version '1.0.1'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  -- RageUI first
  'RageUI/RMenu.lua',
  'RageUI/menu/RageUI.lua',
  'RageUI/menu/Menu.lua',
  'RageUI/menu/MenuController.lua',
  'RageUI/components/*.lua',
  'RageUI/menu/elements/*.lua',
  'RageUI/menu/items/*.lua',
  'RageUI/menu/panels/*.lua',
  'RageUI/menu/windows/*.lua',

  -- Then your scripts
  'RageUI/configk2r.lua',
  'client/**.lua'
}

server_scripts {
  'server/**.lua'
}

dependencies {
  'es_extended',
  'qtarget',
  'ox_lib'
}
