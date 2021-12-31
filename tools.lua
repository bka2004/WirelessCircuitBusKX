local Factories = require "factories"


local function Tools(modData)

    local self = {}

    local modData = modData
    local factories = Factories(modData)


    function self.GetOrCreatePlayerSettings(playerId)

        local playerSettings = modData.persisted.playerSettings[playerId]
        if (playerSettings) then
            return playerSettings
        end

        modData.persisted.playerSettings[playerId] = factories.CreatePlayerData(playerId)

        return modData.persisted.playerSettings[playerId]

    end


    function self.ChannelSetsAsLocalizedStringList(channelSets)
        local localizeStringList = {}
        for name,_ in pairs(channelSets) do
          localizeStringList[#localizeStringList + 1] = name --{"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.ChannelsAsLocalizedStringList(channels)
        local localizeStringList = {}
        for _, name in pairs(channels) do
          localizeStringList[#localizeStringList + 1] = name -- {"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.BussesAsLocalizedStringList(busses, channelSets)
        local localizeStringList = {}
        for name, bus in pairs(busses) do
            local usedChannelSet = bus.channelSet
            if (not usedChannelSet) then
                localizeStringList[#localizeStringList + 1] = self.GetBusNameDisplayString(name) .. " - <error: referenced channelset not found:'" .. bus.channelSet.name .. ">"
            else
                localizeStringList[#localizeStringList + 1] = self.GetBusNameDisplayString(name) .. " - " .. bus.channelSet.name
            end

        end
      
        return localizeStringList
    end


    function self.BussesAsLocalizedStringListSorted(busses, channelSets)
        local localizeStringList = self.BussesAsLocalizedStringList(busses, channelSets)
        table.sort(localizeStringList)
      
        return localizeStringList
    end


    function self.KeyFromDisplayString(displayString)
        return displayString:sub(displayString:find("{") + 1, displayString:find("}") - 1)
--        return displayString:sub(1, displayString:find(" ") - 1)
    end

    
    function self.GetBusNameDisplayString(busName)
        return "{" .. busName .. "}"
    end


    function self.GetIndexOfDropdownItem(items, item, dropdownItemModifier)

        for i, name in pairs(items) do
            if (dropdownItemModifier ~= nil) then
                name = dropdownItemModifier(name)
            end
            if (name == item) then
                return i
            end
        end

        return 0

    end


    function self.CallEventHandler(event, eventHandler)

        local handled = false
      
        for _,handleFunction  in pairs(eventHandler) do
            if (not handled) then
              handled = handleFunction(event)
            end      
        end

        return handled
    end


    function self.deepTableCopy(orig, copies)
        copies = copies or {}
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            if copies[orig] then
                copy = copies[orig]
            else
                copy = {}
                copies[orig] = copy
                for orig_key, orig_value in next, orig, nil do
                    copy[self.deepTableCopy(orig_key, copies)] = self.deepTableCopy(orig_value, copies)
                end
                setmetatable(copy, self.deepTableCopy(getmetatable(orig), copies))
            end
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end


    function self.GetDefaultGuiPositionFor(playerId)

        local x = game.players[playerId].display_resolution.width / 2 - 100
        local y = game.players[playerId].display_resolution.height / 2 - 50

        return {x = x, y = y}

    end


    function self.GetGuiPosition(playerId, guiType)

        local playerSettings = modData.persisted.playerSettings[playerId]
        if (playerSettings) then
            local position = playerSettings.guiPositions[guiType]
            if (position) then
                return position
            end
        end

        return self.GetDefaultGuiPositionFor(playerId)

    end


    function self.SaveGuiPosition(position, playerId, guiType)


        local playerSettings = self.GetOrCreatePlayerSettings(playerId)

        playerSettings.guiPositions[guiType] = position

    end


    function self.CreateAndRememberGuiElement(guiType, parent, elementSpec)

        local guiElement = parent.add(elementSpec)
        modData.persisted.guiElements[guiType][elementSpec.name] = guiElement

        return guiElement

    end


    function self.RetrieveGuiElement(guiType, elementName)

        return modData.persisted.guiElements[guiType][elementName]

    end


    function self.ForgetGuiElements(guiType)

        modData.persisted.guiElements[guiType] = {}
        
    end


    function self.PositionsAreEqual(position1, position2)

        return
          position1.x == position2.x
          and position1.y == position2.y
        
    end


    return self
      
end


return Tools