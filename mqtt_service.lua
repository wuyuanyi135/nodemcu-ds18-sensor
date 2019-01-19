if mqtt_service ~= nil then
    return mqtt_service
end
mqtt_service = {}

local myow = require "myow"
local config = require "config"
local timer_read = tmr.create()
local mqtt_object = nil

mqtt_service.init = function () 
    print("Initializing MQTT service...")
    mqtt_object = mqtt.Client("clientid", 5, nil, nil)
    mqtt_object:lwt("device/"..node.chipid().."/status","off",0, 1)
    mqtt_object:on ("offline", function(client)
        print("Connection lost, reset")
        node.restart()
    end)
    
    mqtt_object:connect("192.168.43.1",1883,0, 0, function()
        print("connected")
        mqtt_object:publish("device/"..node.chipid().."/status", "on", 0, 1);
    end)
    timer_read:start()
end

 function publish(address, data)
    mqtt_object:publish("device/"..node.chipid().."/sensor/".. address, data, 0, 0)
end


function readtask()
    myow.readAll()
    myow.broadcastConvert()
    for i=1,#myow.addr do
        for k,v in pairs(myow.addr[i]) do
            publish(k,v);
            print(k,v)
        end
    end
end
timer_read:register(config.read_interval, tmr.ALARM_AUTO, readtask)

return mqtt_service