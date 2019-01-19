local pin = 1
local count = 0

if myow ~= nil then
    -- already initialized, return the single instance
    return myow
end

myow = {}
myow.addr = {}
function myow.init()
    ow.setup(pin)
    gpio.mode(pin, gpio.OUTPUT, gpio.PULLUP)
end

function myow.search()
    myow.addr = {}
    ow.reset(pin)
    ow.search(pin)
    ow.reset_search(pin)
    repeat 
        count = count + 1
        tmp = ow.search(pin)
        if tmp ~= nil then
            local strtmp = ""
            for i=1,#tmp do
                strtmp = strtmp .. string.format("%x", string.byte(tmp, i))
            end
            temp_table = {}
            temp_table["address"] = strtmp
            temp_table["raw"] = tmp
            table.insert(myow.addr, temp_table)
        end
        tmr.wdclr()
    until tmp == nil
    ow.reset(pin)
end

function myow.broadcastConvert(interval)
    ow.reset(pin)
    ow.skip(pin)
    ow.write(pin, 0x44, 1)
    ow.reset(pin)
end

function myow.config(speed)
    ow.reset(pin)
    ow.skip(pin)
    ow.write(pin, 0x4e, 1)
    ow.write(pin, 0x00, 1)
    ow.write(pin, 0x00, 1)
    ow.write(pin, 0x4e, 1)
    local reg = bit.lshift(speed, 5)
    reg = bit.bor(reg, 0x1f)
    ow.write(pin, reg, 1)
    ow.reset(pin)
end

function myow.read(address)
    ow.reset(pin)
    ow.select(pin, address)
    ow.write(pin, 0xBE, 0)
    
    local tlow = ow.read(pin)
    local thigh = ow.read(pin)

    local t = (tlow + thigh * 256) 
    if (t > 32767) then
        t = t - 65536
    end
    ow.reset(pin)
    return (t*0.0625)
end

function myow.readAll() 
    for i, v in ipairs(myow.addr) do
        v.data = myow.read(v.raw);       
        tmr.wdclr()
    end
end

return myow
