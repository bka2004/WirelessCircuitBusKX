

local function SelectionTool(modData, gui)

    local self = {}

    local modData = modData
    local gui = gui


    function self.ExtractBusses(event)
        
        local busses = {}

        for _, entity in pairs(event.entities) do
            busses[modData.persisted.nodesById[entity.unit_number].settings.busName] = true
        end

        return busses

    end


    function self.GetPrefixAndNumericIndex(busName)
        local prefix, index = string.match(busName, "^(.-)([0-9]*)$")

        if not index or index == "" then
            return prefix, 0
        end

        return prefix, tonumber(index)
    end


    -- function self.GetHighestNumericIndexForPrefix(busNamePrefix)

    --     local highestIndex = 0

    --     for busName, _ in pairs(modData.persisted.busses) do
    --         local curPrefix, curIndex = self.GetPrefixAndNumericIndex(busName)
    --         if (curPrefix == busNamePrefix and curIndex > highestIndex) then
    --             highestIndex = curIndex
    --         end
    --     end

    --     return highestIndex

    -- end


    function self.CalculateDefaultMappings(busses)

        local highestSeenIndexByPrefix = {}

        for bus, _ in pairs(busses) do
            local prefix, index = self.GetPrefixAndNumericIndex(bus)
            if (highestSeenIndexByPrefix[prefix] == nil) then
                highestSeenIndexByPrefix[prefix] = index
            else 
                if (highestSeenIndexByPrefix[prefix] < index) then
                    highestSeenIndexByPrefix[prefix] = index
                end
            end
        end

        -- for bus, _ in pairs(busses) do
        --     local prefix, _ = self.GetPrefixAndNumericIndex(bus)
        --     if (highestSeenIndexByPrefix[prefix] == nil) then
        --         highestSeenIndexByPrefix[prefix] = self.GetHighestNumericIndexForPrefix(prefix)
        --     end
        -- end

        local resultingMappings = {}

        for bus, _ in pairs(busses) do
            local curPrefix, _ = self.GetPrefixAndNumericIndex(bus)
            resultingMappings[bus] = curPrefix .. highestSeenIndexByPrefix[curPrefix] + 1
            highestSeenIndexByPrefix[curPrefix] = highestSeenIndexByPrefix[curPrefix] + 1
        end

        return resultingMappings

    end


    function self.OnSelection(event)

        if (event.item ~= "bus-assigner") then
            return
        end

        local foundBusses = self.ExtractBusses(event)

        local proposedMappings = self.CalculateDefaultMappings(foundBusses)

        local player = game.players[event.player_index]
        gui.GetBusAssignGui().Show(player, proposedMappings, event.entities)

    end


    return self

end


return SelectionTool