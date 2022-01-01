local Factories = require "factories"
local NodeStorage = require "node_storage"
local Tools = require "tools"


local function Ghosts(modData)

    local self =
    {
    }

    local modData = modData
    local factories = Factories(modData)
    local nodeStorage = NodeStorage(modData)
    local tools = Tools(modData)


    function self.AddPending(ghost)
        local settings = ghost.tags and ghost.tags.sourceBusNodeSettings or nil
        self.AddPendingWithSettings(ghost, settings)
    end

    function self.AddPendingWithSettings(ghost, settings)

        if (not self.GetPendingGhostsArray()) then
            self.InitPendingGhostsArray()
        end

        local position = ghost.position
        self.AppendToPendingGhostsArray({ position = position, settings = settings })

    end


    function self.GetPendingGhostsArray()
        return modData.persisted.pendingGhosts
    end


    function self.AppendToPendingGhostsArray(pendingGhost)
        modData.persisted.pendingGhosts[#modData.persisted.pendingGhosts + 1] = pendingGhost
    end


    function self.RemovePendingGhostAtPosition(position)
        modData.persisted.pendingGhosts[position] = nil
    end


    function self.InitPendingGhostsArray()
        modData.persisted.pendingGhosts = {}
    end


    function self.UpdateBusOfPendingGhost(ghostPosition, busName)
        local pendingGhosts = self.GetPendingGhostsArray()
        if (not pendingGhosts) then
            return
        end
        for _, currentPendingGhost in pairs(pendingGhosts) do
            if (tools.PositionsAreEqual(currentPendingGhost.position, ghostPosition)) then
                currentPendingGhost.settings.busName = busName
                return
            end
        end
    end
    

    function self.CheckPendingGhostsForRevival()

        if (not self.GetPendingGhostsArray()) then
            return
        end

        for i, ghost_data in pairs(self.GetPendingGhostsArray()) do

            local entityAtPosition = game.surfaces["nauvis"].find_entity("bus-node", ghost_data.position)
            if (entityAtPosition) then

                local newNodeId = entityAtPosition.unit_number
                nodeStorage.StoreNewNodeWithSettings(factories.CreateNode(newNodeId, entityAtPosition), newNodeId, ghost_data.settings)

                self.RemovePendingGhostAtPosition(i)

            end

        end
    end

    return self
end


return Ghosts