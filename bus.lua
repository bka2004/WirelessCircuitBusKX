local Channel = require "channel"
--local BusNode = require "bus_node"

local function Bus(modData)

    local self = {}

    local modData = modData
    local channel = Channel(modData)
--    local busNode = BusNode(modData)

    function self.Update(bus)

--        local bus = modData.persisted.busses[busName]
        -- for nodeId, node in pairs(bus.nodes) do
        --     if (node.settings.receive) then
        --         busNode.Update(node, bus)
        --     end
        -- end



        --local channelSet = modData.persisted.channelSets[bus.channelSet]
        if (not bus.channelSet) then
            return
        end

        for _, curChannel in pairs(bus.channels) do
            channel.Update(curChannel)
        end
    end

    return self
end


return Bus