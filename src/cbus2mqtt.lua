-- A resident script to run on a Clipsal 5500SHAC to push Cbus events to MQTT
-- Tested with 5500SHAC firmware v1.6
-- Install this script as a resident script with a sleep interval of 0 seconds


-- **********************************************************************
-- MOSQUITTO DOCUMENTATION
-- https://flukso.github.io/lua-mosquitto/docs/
-- **********************************************************************


--UDP Configuration
udp_host = '127.0.0.1'
udp_port = 5432


mqtt_broker = '<ip address>'
mqtt_username = '<username>'
mqtt_password = '<password>'
mqtt_userid = 'CBUS2MQTT'

mqtt_lwt_topic = 'shac/cbus2ha/lwt'
mqtt_lwt_offline = 'offline'
mqtt_lwt_online = 'online'

mqtt_publish_topic = 'cbus/read/'

mqtt_subscribe_topics = {}
--    "cbus/read/#",
--	"ha/status",
--	"paul/#"
--}



-- load mqtt module
mqtt = require("mosquitto")

log(string.format("Starting CBUS2MQTT - Mosquitto Version %s", mqtt.version()))


-- create new mqtt client
client = mqtt.new(mqtt_userid)


-- C-Bus events to MQTT local listener
server = require('socket').udp()
server:settimeout(1)
server:setsockname(udp_host, udp_port)
log(string.format("CBUS2MQTT - Opened UDP Socket on %s:%u", udp_host, udp_port))


client.ON_CONNECT = function(client1, userdata, flags, rc)
    
    log(string.format("CBUS2MQTT - MQTT Client Connected to %s, Result: %s", mqtt_broker, flags));
    
    client:publish(mqtt_lwt_topic, mqtt_lwt_online, 1, true)
    
    for idx = 1, table.maxn(mqtt_subscribe_topics)
	do
        mid = client:subscribe(mqtt_subscribe_topics[idx], 2);
        log(string.format("Subscribed to topic: %s", mqtt_subscribe_topics[idx]))   
	end
    
    
    -- Reset all channels to not retaining if needed
--	for i = 201, 255 do
--    	client:publish(mqtt_publish_topic .. "254/250/" .. i .. "/state", "", 1, true)
--    	client:publish(mqtt_publish_topic .. "254/250/" .. i .. "/level", "", 1, true)
--	end 
    
end


client.ON_DISCONNECT = function()

    log(string.format("CBUS2MQTT - MQTT disconnected"))
    
    while (client:reconnect() ~= true)
    do
        log(string.format("Error reconnecting to broker . . . Retrying"))
        os.sleep(5)
    end

end


client.ON_SUBSCRIBE = function()
    --log("Successfully subscribed to topic")
end


--client.ON_MESSAGE = function(mid, topic, payload)
--	log(string.format("CBUS2MQTT - Received: %s %s", topic, payload))
--end


function ConnectToBroker(broker)

    while (client:connect(broker) ~= true)
    do
        log(string.format("Error connecting to broker '%s' . . . Retrying", broker))
        os.sleep(5)
    end
end


client:login_set(mqtt_username, mqtt_password);
client:will_set (mqtt_lwt_topic, mqtt_lwt_offline, 1, true);    

ConnectToBroker(mqtt_broker)
client:loop_start()



-- Reset all channels to not retaining if needed
--for i = 11, 40 do
--    client:publish(mqtt_publish_topic .. "254/56/" .. i .. "/state", "", 1, true)
--    client:publish(mqtt_publish_topic .. "254/56/" .. i .. "/level", "", 1, true)
--    log("Message Sent Grp " .. i)
--end 


while true do
	cmd = server:receive()
	if cmd then
      log(string.format('CBUS2MQTT - UDP Msg Recvd: %s', cmd))

    	parts = string.split(cmd, "/")
    	network = 254
    	app = tonumber(parts[2])
        
        if (app == 228) then
            device_id = tonumber(parts[3])
            channel_id = tonumber(parts[4])
            value = tonumber(parts[5])
            mqtt_msg = string.format('%s%u/%u/%u/%u', mqtt_publish_topic, network, app, device_id, channel_id)
            client:publish(mqtt_msg .. "/measurement", value, 1, false)

        elseif (app == 203) then	-- Enable Control
            group = tonumber(parts[3])
            level = tonumber(parts[4])
            state = (level ~= 0) and "ON" or "OFF"
            client:publish(mqtt_publish_topic .. network .. "/" .. app .. "/" .. group .. "/state", state, 1, false)
            client:publish(mqtt_publish_topic .. network .. "/" .. app .. "/" .. group .. "/level", level, 1, false)

        elseif (app == 250) then	-- User Parameters
            group = tonumber(parts[3])
            level = tonumber(parts[4])

            mqtt_msg = string.format('%s%u/%u/%u/level', mqtt_publish_topic, network, app, group)
            log(mqtt_msg, level)
            client:publish(mqtt_msg, level, 1, false)
            
        elseif (app == 255) then	-- Unit Parameters
      
      			log(cmd)
      
            device = tonumber(parts[3])
            channel = tonumber(parts[4])
						value = tonumber(parts[5])
            mqtt_msg = string.format('%s%u/%u/%u/%u/value', mqtt_publish_topic, network, app, device, channel)
            log(mqtt_msg)
      			client:publish(mqtt_msg, value, 1, false)
            
        else
            group = tonumber(parts[3])
            level = tonumber(parts[4])
            state = (level ~= 0) and "ON" or "OFF"
            client:publish(mqtt_publish_topic .. network .. "/" .. app .. "/" .. group .. "/state", state, 1, false)
            client:publish(mqtt_publish_topic .. network .. "/" .. app .. "/" .. group .. "/level", level, 1, false)
        end
	end
end