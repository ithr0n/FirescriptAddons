fx_version 'cerulean'
game 'gta5'

description 'inferno-pass-alarm'
version '1.0.0'

-- Client Script
client_script "client.lua"

-- Server Script
server_script "server.lua"

-- NUI Page
ui_page "html/index.html"

-- Required Files
files {
    "html/index.html",
    "html/sounds/on.mp3",
    "html/sounds/off.mp3",
    "html/sounds/stage1.mp3",
    "html/sounds/stage2.mp3"
}