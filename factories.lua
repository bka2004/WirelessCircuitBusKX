local function Factories(modData)
    local self = {}

    function self.CreateNode(newNodeId, entity)

        return
        {
            id = newNodeId,
            worldEntity = entity,
            settings = { busName = "", channelName = "", direction = modData.constants.nodeDirection.receive },
            currentlyAssignedChannelRef = nil
        }
    end

    -- function self.CreateBusNodeData(entity)

    --     return 
    --     {
    --         worldEntity = entity,
    --         settings = { bus = "", channel = "", direction = modData.constants.nodeDirection.receive }
    --     }

    -- end

    -- function self.CreateBusNodeDataWithSettings(entity, settings)

    --     local newBusData = self.CreateBusNodeData(entity)
    --     newBusData.settings = settings

    --     return newBusData

    -- end


    function self.CreatePlayerData(playerId)

        return
        {
            guiPositions = { }
        }

    end


    function self.CreateBus(busName)
        return
        {
            name = busName,
            channelSet = {},
            channels = {}
        }
    end


    function self.CreateBusWithChannelSet(busName, channelSet)
        local newBus = self.CreateBus(busName)
        newBus.channelSet = channelSet
        return newBus
    end


    function self.CreateChannel(channelName)
        return
        {
            name = channelName,
            nodes = {}
        }
    end


    function self.CreateChannelSet(channelSetName)
        return
        {
            name = channelSetName,
            channels = {}
        }
    end

    return self
end


return Factories