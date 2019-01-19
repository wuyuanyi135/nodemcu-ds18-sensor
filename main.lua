local config = require "config"
local wireless = require "wireless"
local myow = require "myow"
local mqtt_service = require "mqtt_service"
local speed = 3

function main_loop() 
    mqtt_service.init()
end

wireless.setup(main_loop)
myow.init()
myow.search()
print ("Attached sensor count: ", #myow.addr)
myow.broadcastConvert()
