local Factories = require "factories"
local NodeStorage = require "node_storage"


local function Ghosts(modData)

    local self =
    {
        pending = {}
    }

    local modData = modData
    local factories = Factories(modData)
    local nodeStorage = NodeStorage(modData)

    function self.AddPending(ghost)
        local position = ghost.position
        local settings = ghost.tags and ghost.tags.sourceBusNodeSettings or nil
        self.pending[#self.pending+1] =  { position = position, settings = settings }
    end

    function self.AddPendingWithSettings(ghost, settings)

        local position = ghost.position
        self.pending[#self.pending+1] =  { position = position, settings = settings }

    end


    function self.CheckPendingGhostsForRevival()

        for i, ghost_data in pairs(self.pending) do

            local entityAtPosition = game.surfaces["nauvis"].find_entity("bus-node", ghost_data.position)
            if (entityAtPosition) then

                local newNodeId = entityAtPosition.unit_number
                nodeStorage.StoreNewNodeWithSettings(factories.CreateNode(newNodeId, entityAtPosition), newNodeId, ghost_data.settings)

                self.pending[i] = nil

            end

        end
    end

    return self
end


return Ghosts