local function Ghosts(modData)

    local self =
    {
        pending = {}
    }

    local modData = modData

    function self.AddPending(ghost)

        self.pending[#self.pending+1] =  { position = ghost.position, settings = ghost.tags.sourceBusNodeSettings }

    end


    function self.CheckPendingGhostsForRevival()

        for i, ghost_data in pairs(self.pending) do

            local entityAtPosition = game.surfaces["nauvis"].find_entity("bus-node", ghost_data.position)
            if (entityAtPosition) then

                modData.tools.registerNodeWithSettings(entityAtPosition.unit_number, entityAtPosition, ghost_data.settings)

                self.pending[i] = nil

            end

        end
    end

    return self
end


return Ghosts