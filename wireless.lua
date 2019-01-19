if wireless ~= nil then
    return wireless
end
wireless = {}
local config = require "config"
local wireless_tmr = tmr.create()
local _got_ip_cb = function()end
function wireless.setup(got_ip_cb)
    _got_ip_cb = got_ip_cb
    wifi.setmode(wifi.STATION)
    config_table = {}
    config_table.ssid = config.host_ssid
    config_table.pwd = config.host_password
    config_table.save = false
    config_table.connected_cb = function()
        print("WiFi connected")
    end
    config_table.disconnected_cb = function(_, _, reason)
        print("WiFi disconnected: " .. reason)
    end
    
    wifi.sta.config(config_table)
    print("Setting SSID:" .. config.host_ssid)
    wifi.sta.autoconnect(1)
    wireless_tmr:register(1000, tmr.ALARM_AUTO, function()
        local status = wifi.sta.status()
        if status == wifi.STA_CONNECTING then
            print("Connecting ...")
        elseif status == wifi.STA_GOTIP then
            wireless_tmr:stop()
            wireless_tmr:unregister()
            _got_ip_cb()
        end
    end)
    wireless_tmr:start()
end


    

return wireless
