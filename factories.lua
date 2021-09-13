local function Factories(modData)
    local self = {}

    function self.CreateBusNodeData(entity)

        return 
        {
            worldEntity = entity,
            settings = { bus = "", channel = "", direction = modData.constants.nodeDirection.receive }
        }

    end

    function self.CreateBusNodeDataWithSettings(entity, settings)

        local newBusData = self.CreateBusNodeData(entity)
        newBusData.settings = settings

        return newBusData

    end


    function self.CreatePlayerData(playerId)

        return
        {
            guiPositions = { }
        }

    end

    return self
end


return Factories